_ = require 'lodash' #lodash
$ = require './index' #index

argv = require('minimist')(process.argv.slice 2) #argv

gulp = require 'gulp' #gulp
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
concat = require 'gulp-concat'
replace = require 'gulp-replace'
using = require 'gulp-using'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify' #minify
lint = require 'gulp-coffeelint' #lint

colors = require 'colors/safe'

#error
#uncaughtException
process.on 'uncaughtException', (err) -> $.log err.stack

#function

#bind
task = {}
$.task = (name, fn) ->
  gulp.task name, ->
    #show base
    $.info 'base', 'running at ' + colors.magenta project.base
    #do
    task[name]()
  task[name] = fn

#param
#project
project = base: process.cwd()
project.name = project.base.replace /.*\\|.*\//, ''

path = source: './source'
path.coffee = path.source + '/**/*.coffee'

_coffee = -> coffee map: true

#watch
$.task 'watch', -> watch path.source + '/script/include/**/*.coffee', -> task.build()

#build
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
    gulp.src (path.source + '/script/include/' + a + '.coffee' for a in list)
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
  gulp.src path.coffee
  .pipe plumber()
  .pipe using()
  .pipe lint()
  .pipe lint.reporter()

#prepare
$.task 'prepare', ->

  #gulpfile
  gulp.src './gulpfile.coffee'
  .pipe plumber()
  .pipe using()
  .pipe _coffee()
  .pipe gulp.dest ''

  #coffeelint
  gulp.src './coffeelint.cson'
  .pipe plumber()
  .pipe using()
  .pipe cson()
  .pipe gulp.dest ''

#work
$.task 'work', -> $.shell 'gulp watch' #watch

#noop
$.task 'noop', -> null

#test
$.task 'test', -> $.shell 'node test.js'

#set
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