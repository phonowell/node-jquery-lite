_ = require 'lodash'
$ = require './source/script/core.js'

#function
test = (a, b, msg) ->
  if a == b
    $.info 'success', msg
  else
    $.info 'fail', msg

#version
do ->
  a = '0.2.9'
  test $.version, a, '$.version is ' + a

#type
do ->
  for a in [
    [199, 'number']
    ['hello world', 'string']
    [new Buffer('buffer'), 'buffer']
    [true, 'boolean']
    [[1, 2], 'array']
    [{a: 1, b: 2}, 'object']
    [null, 'null']
    [undefined, 'undefined']
    [NaN, 'NaN']
  ]
    test $.type(a[0]), a[1], '$.type(' + $.parseString(a[0]) + ') is ' + a[1]