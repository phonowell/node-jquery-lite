$$ = require 'fire-keeper'
{_, Promise} = $$.library
co = Promise.coroutine

# task

###

  build
  lint
  prepare
  test
  set
  watch
  work

###

$$.task 'build', co ->

  yield $$.remove [
    './index.js'
    './source/index.js'
  ]

  yield $$.compile './source/index.coffee',
    minify: false
  yield $$.copy './source/index.js', './'

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
    './test/**/*.coffee'
  ]

$$.task 'prepare', co ->

  yield $$.remove './test/test.js'
  yield $$.compile './test/test.coffee',
    minify: false

$$.task 'test', co ->

  yield $$.compile './test/**/*.coffee'

  yield $$.shell 'npm test'

  yield $$.remove './test/**/*.js'

$$.task 'set', co ->

  if !(ver = $$.argv.version) then return

  yield $$.replace './package.json'
  , /"version": "[\d.]+"/, "\"version\": \"#{ver}\""

  yield $$.replace './source/include/init.coffee'
  , /VERSION = '[\d.]+'/, "VERSION = '#{ver}'"

  yield $$.replace './test/test.coffee'
  , /VERSION = '[\d.]+'/, "VERSION = '#{ver}'"

$$.task 'watch', ->

  # build

  deb = _.debounce $$.task('build'), 1e3
  $$.watch [
    './source/index.coffee'
    './source/include/**/*.coffee'
  ], deb

  # test

  $test = './test/test.coffee'
  deb = _.debounce ->
    $$.compile $test,
      minify: false
  , 1e3
  $$.watch $test, deb

$$.task 'work', -> $$.shell 'start gulp watch'