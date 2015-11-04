_ = require 'lodash'
$ = require './index'

express = require 'express'
app = express()
bodyParser = require 'body-parser'

#function
test = (a, b, msg) ->
  if a == b
    $.info 'success', msg
  else
    $.info 'fail', msg
    fails++

fails = 0

#version
do ->
  $.i '---'
  a = '0.3.2'
  test $.version, a, '$.version is ' + a

#type
do ->
  $.i '---'
  for a in [
    [199, 'number']
    ['hello world', 'string']
    [true, 'boolean']
    [[1, 2, 3], 'array']
    [{a: 1, b: 2}, 'object']
    [_.noop, 'function']
    [new Date(), 'date']
    [new Error(), 'error']
    [new Buffer('buffer'), 'buffer']
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
    [_.now() - 45e3, '45秒前']
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
    [true, 'true']
    [[1, 2, 3], '[1,2,3]']
    [{a: 1, b: 2}, '{"a":1,"b":2}']
    [new Date(), (new Date()).toString()]
    [new Error('concert'), (new Error('concert')).toString()]
    [new Buffer('buffer'), 'buffer']
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
    [true, null]
    ['[1, 2, 3]', [1,2,3]]
    ['{"a":1,"b":2}', {a: 1, b: 2}]
    [new Date(), null]
    [new Error('error'), null]
    [new Buffer('buffer'), null]
    [null, null]
    [undefined, null]
    [NaN, null]
  ]
    test _.isEqual($.parseJson(a[0]), a[1]), true, '$.parseJson(' + $.parseString(a[0]) + ') is ' + a[1]

#ajax
do ->

  #server
  app.use bodyParser.urlencoded extended: true

  #route
  app.get '/ping', (req, res) -> res.send req.body.salt
  app.get '/json', (req, res) -> res.json salt: parseInt req.body.salt
  app.post '/ping', (req, res) -> res.send req.body.salt
  app.post '/json', (req, res) -> res.json salt: parseInt req.body.salt

  port = 9453
  app.listen port
  base = 'http://localhost:' + port

  $.i '---'

  salt = _.now()

  #ping
  $.get base + '/ping', salt: salt
  .fail (data) -> $.info 'fail', '$.get("/ping") - ' + data
  .done (data) ->
    if salt != parseInt data
      $.info 'fail', '$.get("/ping") - ' + data
      return
    $.info 'success', '$.get("/ping")'

  #json
  $.get base + '/json', salt: salt
  .fail (data) -> $.info 'fail', '$.get("/json") - ' + data
  .done (data) ->
    if salt != data.salt
      $.info 'fail', '$.get("/json") - ' + $.parseString data
      return
    $.info 'success', '$.get("/json")'

  #ping
  $.post base + '/ping', salt: salt
  .fail (data) -> $.info 'fail', '$.post("/ping") - ' + data
  .done (data) ->
    if salt != parseInt data
      $.info 'fail', '$.post("/ping") - ' + data
      return
    $.info 'success', '$.post("/ping")'

  #json
  $.post base + '/json', salt: salt
  .fail (data) -> $.info 'fail', '$.post("/json") - ' + data
  .done (data) ->
    if salt != data.salt
      $.info 'fail', '$.post("/json") - ' + $.parseString data
      return
    $.info 'success', '$.post("/json")'

  $.next 1e3, -> process.exit()

#final
$.i '---'
$.info 'result', 'These has got ' + fails + ' fail(s).'