#require
gulp = require 'gulp'

#gutil
gutil = require 'gulp-util'

#changed
changed = require 'gulp-changed'

#function

#log
log = console.log

#start
start = ->
  #check
  if !start.ready
    return

  #server
  server = require 'gulp-express'
  #run
  process.nextTick ->
    server.run file: 'test.js'

#task

#coffee

#lib
gulp.task 'lib', ->
  #require
  coffee = require 'gulp-coffee'
  uglify = require 'gulp-uglify'
  concat = require 'gulp-concat'

  #src
  src = ('./src/lib/' + a + '.coffee' for a in ['ready', 'error', 'basic', 'parse', 'ajax', 'promise', 'etc', 'init'])

  gulp.src src
  #concat
  .pipe concat 'index.coffee'
  #coffee
  .pipe coffee(bare: true).on('error', gutil.log)
  #uglify
  .pipe uglify().on('error', gutil.log)
  #output
  .pipe gulp.dest './'
  #start
  start()

#coffee
gulp.task 'coffee', ->
  #require
  coffee = require 'gulp-coffee'
  uglify = require 'gulp-uglify'

  gulp.src './src/*.coffee'
  #changed
  .pipe changed './', extension: '.js'
  #coffee
  .pipe coffee(bare: true).on('error', gutil.log)
  #uglify
  .pipe uglify().on('error', gutil.log)
  #output
  .pipe gulp.dest './'
  #start
  start()

#server
gulp.task 'server', ->
  #ready
  start.ready = true
  #start
  start()

#watch
gulp.task 'watch', ->

  #coffee
  gulp.watch 'src/*.coffee', ['coffee']

  #lib
  gulp.watch 'src/lib/*.coffee', ['lib']

#default
gulp.task 'default', ['coffee', 'lib', 'watch', 'server']