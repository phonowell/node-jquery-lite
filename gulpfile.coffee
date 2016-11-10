_ = require 'lodash'
$ = {}
$.i = (msg) -> console.log msg
$.info = (arg...) -> $.i _.last arg
try $ = require './index'

argv = require('minimist')(process.argv.slice 2)

gulp = require 'gulp'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
include = require 'gulp-include'
replace = require 'gulp-replace'
using = require 'gulp-using'

coffee = require 'gulp-coffee'
yaml = require 'gulp-yaml'

uglify = require 'gulp-uglify'
lint = require 'gulp-coffeelint'

process.on 'uncaughtException', (err) -> $.log err.stack # error

# function

# bind
task = {}
$.task = (name, fn) ->
  gulp.task name, ->
    $.info 'base', "running at #{project.base}"
    task[name]()
  task[name] = fn

# param
# project
project = base: process.cwd()
project.name = project.base.replace /.*\\|.*\//, ''

path = source: './source'
path.coffee = "#{path.source}/**/*.coffee"

_coffee = -> coffee map: true
_yaml = -> yaml safe: true

$.task 'watch', ->
  list = [
    "#{path.source}/script/index.coffee"
    "#{path.source}/script/include/**/*.coffee"
  ]
  watch list, -> task.build()

$.task 'build', (callback) ->
  fn = {}

  fn.coffee = (cb) ->
    gulp.src "#{path.source}/script/index.coffee"
    .pipe plumber()
    .pipe using()
    .pipe include()
    .pipe _coffee()
    .pipe uglify()
    .pipe gulp.dest './'
    .on 'end', -> cb?()

  fn.coffee()

# lint
$.task 'lint', ->
  # coffee lint
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

    # version
    ver = argv.version

    # function
    fn = {}

    # package
    fn.package = (cb) ->
      src = 'package.json'
      gulp.src src
      .pipe plumber()
      .pipe using()
      .pipe replace /"version": "[\d\.]+"/, "\"version\": \"#{ver}\""
      .pipe gulp.dest ''
      .on 'end', -> cb?()

    # init
    fn.init = (cb) ->
      src = "#{path.source}/script/include/init.coffee"
      gulp.src src
      .pipe plumber()
      .pipe using()
      .pipe replace /version: '[\d\.]+'/, "version: '#{ver}'"
      .pipe gulp.dest path.source + '/script/include'
      .on 'end', -> cb?()

    # test
    fn.test = (cb) ->
      src = 'test.coffee'
      gulp.src src
      .pipe plumber()
      .pipe using()
      .pipe replace /a = '[\d\.]+'/, "a = '#{ver}'"
      .pipe gulp.dest ''
      .on 'end', -> cb?()

    # execute
    fn.package -> fn.init -> fn.test()