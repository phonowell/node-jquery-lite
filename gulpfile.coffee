_ = require 'lodash'
$ = {}
$.i = (msg) -> console.log msg
$.info = (arg...) -> $.i _.last arg
try $ = require './index'

argv = require('minimist')(process.argv.slice 2)

gulp = require 'gulp'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
concat = require 'gulp-concat'
replace = require 'gulp-replace'
using = require 'gulp-using'

coffee = require 'gulp-coffee'
yaml = require 'gulp-yaml'

uglify = require 'gulp-uglify'
lint = require 'gulp-coffeelint'

process.on 'uncaughtException', (err) -> $.log err.stack #error

#function

#bind
task = {}
$.task = (name, fn) ->
  gulp.task name, ->
    $.info 'base', "running at #{project.base}"
    task[name]()
  task[name] = fn

#param
#project
project = base: process.cwd()
project.name = project.base.replace /.*\\|.*\//, ''

path = source: './source'
path.coffee = "#{path.source}/**/*.coffee"

_coffee = -> coffee map: true
_yaml = -> yaml safe: true

$.task 'watch', ->
  watch "#{path.source}/script/include/**/*.coffee", -> task.build()

$.task 'build', (callback) ->
  fn = {}

  fn.coffee = _.throttle ->
    list = [
      'init'
      'error'
      'basic'
      'callback'
      'promise'
      'parse'
      'ajax'
      'etc'
    ]
    list = ("#{path.source}/script/include/#{a}.coffee" for a in list)
    $.i list
    gulp.src list
    .pipe plumber()
    .pipe using()
    .pipe concat 'index.coffee'
    .pipe gulp.dest './'
    .on 'end', ->
      gulp.src './index.coffee'
      .pipe plumber()
      .pipe using()
      .pipe _coffee()
      .pipe uglify()
      .pipe gulp.dest './'

      callback?()

  fn.coffee()

#lint
$.task 'lint', ->
  #coffee lint
  gulp.src ['./gulpfile.coffee', './test.coffee', path.coffee]
  .pipe plumber()
  .pipe using()
  .pipe lint()
  .pipe lint.reporter()

$.task 'prepare', ->
  gulp.src './coffeelint.yml'
  .pipe plumber()
  .pipe using()
  .pipe _yaml()
  .pipe gulp.dest './'

$.task 'work', -> $.shell 'gulp watch'
$.task 'noop', -> null
$.task 'test', -> $.shell 'node test.js'

$.task 'set', ->
  if argv.version
    fs = require 'fs'

    #version
    ver = argv.version

    #function
    fn = {}

    #package
    fn.package = ->
      gulp.src 'package.json'
      .pipe plumber()
      .pipe using()
      .pipe replace /"version": "[\d\.]+"/, "\"version\": \"#{ver}\""
      .pipe gulp.dest ''

    #init
    fn.init = ->
      gulp.src path.source + '/script/include/init.coffee'
      .pipe plumber()
      .pipe using()
      .pipe replace /version: '[\d\.]+'/, "version: '#{ver}'"
      .pipe gulp.dest path.source + '/script/include'

    #test
    fn.test = ->
      gulp.src 'test.coffee'
      .pipe plumber()
      .pipe using()
      .pipe replace /a = '[\d\.]+'/, "a = '#{ver}'"
      .pipe gulp.dest ''

    #execute
    fn.package()
    fn.init()
    fn.test()