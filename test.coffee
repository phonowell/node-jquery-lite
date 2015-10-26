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
  $.i '---'
  a = '0.2.9'
  test $.version, a, '$.version is ' + a

#type
do ->
  $.i '---'
  for a in [
    [199, 'number']
    ['hello world', 'string']
    [new Buffer('buffer'), 'buffer']
    [true, 'boolean']
    [[1, 2, 3], 'array']
    [{a: 1, b: 2}, 'object']
    [null, 'null']
    [undefined, 'undefined']
    [NaN, 'NaN']
  ]
    test $.type(a[0]), a[1], '$.type(' + $.parseString(a[0]) + ') is ' + a[1]

#parse time
do ->
  $.i '---'
  for a in [
    [_.now(), '刚刚']
    [_.now() - 1e3, '1秒前']
    [_.now() - 6e4, '1分钟前']
    [_.now() - 36e5, '1小时前']
    ['2012.12.21 12:00', '2012年12月21日(星期五) 12时00分']
  ]
    test $.parseTime(a[0]), a[1], '$.parseTime(' + $.parseString(a[0]) + ') is ' + a[1]

#parse string
do ->
  $.i '---'
  for a in [
    [1096, '1096']
    ['hello world', 'hello world']
    [new Buffer('buffer'), 'buffer']
    [true, 'true']
    [[1, 2, 3], '[1,2,3]']
    [{a: 1, b: 2}, '{"a":1,"b":2}']
    [null, 'null']
    [undefined, 'undefined']
    [NaN, 'NaN']
  ]
    test $.parseString(a[0]), a[1], '$.parseString(' + $.parseString(a[0]) + ') is ' + a[1]

#parse pts
do ->
  $.i '---'
  for a in [
    [0, '0']
    [100, '100']
    [1e3, '1,000']
    [1e4, '10,000']
    [1e5, '10万']
    [1234567, '123.4万']
  ]
    test $.parsePts(a[0]), a[1], '$.parsePts(' + $.parseString(a[0]) + ') is ' + a[1]

#parse json
do ->
  $.i '---'
  for a in [
    [1096, null]
    ['hello world', null]
    [new Buffer('buffer'), null]
    [true, null]
    ['[1, 2, 3]', [1,2,3]]
    ['{"a":1,"b":2}', {a: 1, b: 2}]
    [null, null]
    [undefined, null]
    [NaN, null]
  ]
    test _.isEqual($.parseJson(a[0]), a[1]), true, '$.parseJson(' + $.parseString(a[0]) + ') is ' + a[1]