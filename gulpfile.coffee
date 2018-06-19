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

  await $$.remove_ './index.js'

  await $$.compile_ './source/index.coffee', './',
    minify: false

$$.task 'lint', ->

  await $$.task('kokoro')()

  await $$.lint_ [
    './gulpfile.coffee'
    './source/**/*.coffee'
    './test/**/*.coffee'
  ]

$$.task 'test', ->

  await $$.compile_ './test/**/*.coffee'

  await $$.shell_ 'npm test'

  await $$.remove_ './test/**/*.js'

$$.task 'set', ->

  {ver} = $$.argv
  if !ver
    throw new Error 'empty ver'

  pkg = './package.json'

  data = await $$.read_ pkg
  data.version = ver
  await $$.write_ pkg, data