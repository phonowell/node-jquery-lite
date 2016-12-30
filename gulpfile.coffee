$$ = require 'fire-keeper'

{_, Promise} = $$.library

co = Promise.coroutine

# config
$$.config 'useHarmony', true

# task

$$.task 'work', co -> yield $$.shell 'gulp watch'

$$.task 'watch', ->
  deb = _.debounce $$.task('build'), 1e3
  $$.watch [
    './source/index.coffee'
    './source/include/**/*.coffee'
  ], deb

$$.task 'build', co ->
  yield $$.delete [
    './index.js'
    './source/index.js'
  ]
  yield $$.compile './source/index.coffee'
  yield $$.copy './source/index.js'

$$.task 'lint', co -> yield $$.lint 'coffee'

$$.task 'prepare', co ->
  yield $$.delete [
    './gulpfile.js'
    './coffeelint.json'
    './test.js'
  ]
  yield $$.compile './gulpfile.coffee'
  yield $$.compile './coffeelint.yml'
  yield $$.compile './test.coffee'

$$.task 'set', co ->

  if !(ver = $$.argv.version) then return

  yield $$.replace './package.json'
  , /"version": "[\d.]+"/, "\"version\": \"#{ver}\""

  yield $$.replace './source/include/init.coffee'
  , /version: '[\d.]+'/, "version: '#{ver}'"

  yield $$.replace './test.coffee'
  , /version = '[\d.]+'/, "version = '#{ver}'"

$$.task 'test', co -> yield $$.shell 'node test.js'