#require
#lodash
_ = require 'lodash'
$ = require './index'
#exec
exec = (require 'child_process').exec

#gulp
gulp = require 'gulp'

#tool
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
concat = require 'gulp-concat'
using = require 'gulp-using'

#type
coffee = require 'gulp-coffee'

#advanced tool

#minify
uglify = require 'gulp-uglify'

#lint
lint = require 'gulp-coffeelint'

#error
#uncaughtException
process.on 'uncaughtException', (err) -> $.log err.stack

#function $

#exec
$.exe = (cmd, callback) ->

  #info
  info = (string) ->
    text = $.trim string
    if text.length
      $.info text.replace /[\r\n]/g, ''

  child = exec cmd
  child.stdout.on 'data', (data) -> info data
  child.stderr.on 'data', (data) -> info data
  child.on 'close', -> callback?()

#bind
task = {}
$.task = (name, fn) ->
  gulp.task name, ->
    #show base
    $.info 'base', 'running at ' + project.base
    #do
    task[name]()
  task[name] = fn

#param
#project
project = base: process.cwd()
project.name = project.base.replace /.*\\|.*\//, ''

path = source: './source/'
path.coffee = path.source + '**/*.coffee'

_coffee = -> coffee map: true

#watch
$.task 'watch', -> watch path.source + 'script/include/**/*.coffee', -> task.build()

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
    gulp.src (path.source + 'script/include/' + a + '.coffee' for a in list)
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
$.task 'work', -> $.exe 'start gulp watch' #watch

#noop
$.task 'noop', -> null

#test
$.task 'test', -> $.exe 'start node test.js'