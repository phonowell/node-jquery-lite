$$ = require 'fire-keeper'
{_, Promise} = $$.library
co = Promise.coroutine

# task

###

  build
  init
  lint
  prepare
  test
  set
  update
  watch
  work

###

$$.task 'build', co ->

  yield $$.remove [
    './index.js'
    './source/index.js'
  ]

  yield $$.compile './source/index.coffee', minify: false
  yield $$.copy './source/index.js', './'

$$.task 'init', co ->

  yield $$.remove './.gitignore'
  yield $$.copy './../kokoro/.gitignore'

  yield $$.remove './.npmignore'
  yield $$.copy './../kokoro/.npmignore'

  yield $$.remove './coffeelint.yml'
  yield $$.copy './../kokoro/coffeelint.yml'

$$.task 'lint', co ->
  yield $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
  ]

$$.task 'prepare', co ->
  yield $$.remove './coffeelint.json'
  yield $$.compile './coffeelint.yml'

  yield $$.remove './test/test.js'
  yield $$.compile './test/test.coffee', minify: false

$$.task 'test', co ->
  yield $$.compile './test/**/*.coffee'
  $$.shell 'start npm test'

$$.task 'set', co ->

  if !(ver = $$.argv.version) then return

  yield $$.replace './package.json'
  , /"version": "[\d.]+"/, "\"version\": \"#{ver}\""

  yield $$.replace './source/include/init.coffee'
  , /VERSION = '[\d.]+'/, "VERSION = '#{ver}'"

  yield $$.replace './test/test.coffee'
  , /VERSION = '[\d.]+'/, "VERSION = '#{ver}'"

$$.task 'update', co ->

  pkg = './package.json'
  yield $$.backup pkg

  p = require pkg
  list = []

  for key of p.devDependencies
    list.push "cnpm r --save-dev #{key}"
    list.push "cnpm i --save-dev #{key}"

  for key of p.dependencies
    list.push "cnpm r --save #{key}"
    list.push "cnpm i --save #{key}"

  yield $$.shell list

  yield $$.remove "#{pkg}.bak"

$$.task 'watch', ->

  deb = _.debounce $$.task('build'), 1e3
  $$.watch [
    './source/index.coffee'
    './source/include/**/*.coffee'
  ], deb

  $test = './test/test.coffee'
  deb = _.debounce ->
    $$.compile $test, minify: false
  , 1e3
  $$.watch $test, deb

$$.task 'work', ->

  yield $$.shell 'start gulp watch'