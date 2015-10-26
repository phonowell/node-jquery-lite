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
    [1, 'number']
  ]
    test $.type(a[0]), a[1], '$.type(' + a[0] + ') is ' + a[1]