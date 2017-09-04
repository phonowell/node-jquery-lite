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

###

$$.task 'build', co ->

  yield $$.remove './index.js'

  yield $$.compile './source/index.coffee', './',
    minify: false

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
