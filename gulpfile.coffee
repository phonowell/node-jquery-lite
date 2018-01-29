$$ = require 'fire-keeper'
{_} = $$.library

# task

###

build()
lint()
test()
set(ver)

###

$$.task 'build', ->

  await $$.remove './index.js'

  await $$.compile './source/index.coffee', './',
    minify: false

$$.task 'lint', ->

  await $$.task('kokoro')()

  await $$.lint [
    './gulpfile.coffee'
    './source/**/*.coffee'
    './test/**/*.coffee'
  ]

$$.task 'test', ->

  await $$.compile './test/**/*.coffee'

  await $$.shell 'npm test'

  await $$.remove './test/**/*.js'

$$.task 'set', ->

  {ver} = $$.argv
  if !ver
    throw new Error 'empty ver'

  pkg = './package.json'

  data = await $$.read pkg
  data.version = ver
  await $$.write pkg, data