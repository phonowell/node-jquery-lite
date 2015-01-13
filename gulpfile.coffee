#============
#require
#============
exec = (require 'child_process').exec

gulp = require 'gulp'
gutil = require 'gulp-util'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
replace = require 'gulp-replace'
clean = require 'gulp-clean'
ignore = require 'gulp-ignore'
concat = require 'gulp-concat'

uglify = require 'gulp-uglify'

jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
cson = require 'gulp-cson'

lint = require 'gulp-coffeelint'

#============
#error
#============
#uncaughtException
process.on 'uncaughtException', (err) -> log err.statck

#============
#function
#============
#log
log = console.log

#============
#param
#============
#base
base = process.cwd()

#============
#task
#============

#watch
gulp.task 'watch', ->

  #lib
  watch './lib/*.coffee', ->
    #src
    src = ('./lib/' + a + '.coffee' for a in ['ready', 'error', 'basic', 'parse', 'ajax', 'promise', 'etc', 'init'])

    gulp.src src
    #concat
    .pipe concat 'index.coffee'
    #coffee
    .pipe coffee(bare: true).on('error', gutil.log)
    #uglify
    .pipe uglify().on('error', gutil.log)
    #output
    .pipe gulp.dest './'

    #delay to clean
    setTimeout ->
      gulp.src './lib/*.js'
      .pipe clean()
    , 1e3

  #lint
  watch ['./**/*.coffee', '!./node_modules/**']
  .pipe lint()
  .pipe lint.reporter()