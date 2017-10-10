$$ = require 'fire-keeper'
{_, Promise} = $$.library
co = Promise.coroutine

# task

###

  build()
  lint()
  test()
  set(ver)

###

$$.task 'build', co ->

  yield $$.remove './index.js'

  yield $$.compile './source/index.coffee', './',
    bare: true
    minify: false

$$.task 'lint', co ->

  yield $$.task('kokoro')()

  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
    './test/**/*.coffee'
  ]

$$.task 'test', co ->

  yield $$.compile './test/**/*.coffee'

  yield $$.shell 'npm test'

  yield $$.remove './test/**/*.js'

$$.task 'set', co ->

  {ver} = $$.argv
  if !ver
    throw new Error 'empty ver'

  yield $$.replace './package.json'
  , /"version": "[\d.]+"/, "\"version\": \"#{ver}\""
