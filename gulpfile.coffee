$ = require './index'
_ = $._

Promise = require 'bluebird'
co = Promise.coroutine

gulp = require 'gulp'

$$ = require 'fire-keeper'
$$.use gulp

# task

gulp.task 'watch', ->

  list = [
    './source/index.coffee'
    './source/include/**/*.coffee'
  ]

  $$.watch list, -> gulp.tasks.build.fn()

gulp.task 'build', co ->
  yield $$.delete [
    './index.js'
    './source/index.js'
  ]
  yield $$.compile './source/index.coffee'
  yield $$.copy './source/index.js'

gulp.task 'lint', co -> yield $$.lint 'coffee'

gulp.task 'prepare', co ->
  yield $$.delete [
    './gulpfile.js'
    './coffeelint.json'
    './test.js'
  ]
  yield $$.compile './gulpfile.coffee'
  yield $$.compile './coffeelint.yml'
  yield $$.compile './test.coffee'

gulp.task 'work', co -> yield $$.shell 'gulp watch'

gulp.task 'set', co ->

  if !(ver = $$.argv.version) then return

  yield $$.replace './package.json'
  , /"version": "[\d.]+"/, "\"version\": \"#{ver}\""

  yield $$.replace './source/include/init.coffee'
  , /version: '[\d.]+'/, "version: '#{ver}'"

  yield $$.replace './test.coffee'
  , /version = '[\d.]+'/, "version = '#{ver}'"

gulp.task 'test', co -> yield $$.shell 'node test.js'

gulp.task 'noop', -> null
