_ = require 'lodash'
$ = require './index'

express = require 'express'
app = express()
bodyParser = require 'body-parser'

colors = require 'colors/safe'

#function
fails = 0
test = (a, b, msg) ->
  if a == b
    $.info 'success', msg
  else
    $.info 'fail', msg
    fails++

divide = -> $.log colors.gray '------'

#version
do ->
  divide()
  a = '0.3.4'
  test $.version, a, '$.version is ' + a

#type
do ->
  divide()
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
  ]
    test $.type(a[0]), a[1], "$.type(#{$.parseString a[0]}) is #{a[1]}"

#parse time
do ->
  divide()
  for a in [
    #before
    [_.now(), false, '刚刚']
    [_.now() - 45e3, false, '45秒前']
    [_.now() - 6e4, false, '1分钟前']
    [_.now() - 36e5, false, '1小时前']
    ['2012.12.21 12:00', false, '2012年12月21日(星期五) 12时00分']
    #after
    [_.now() + 45e3, true, '45秒后']
    [_.now() + 6e4, true, '1分钟后']
    [_.now() + 36e5, true, '1小时后']
    ['2050.12.21 12:00', true, '2050年12月21日(星期三) 12时00分']
    #error
    [_.now() + 1e3, false, '刚刚']
    [_.now() - 45e3, true, '45秒前']
  ]
    #$.i $.parseTime a[0], a[1]
    test $.parseTime(a[0], a[1]), a[2], "$.parseTime(#{$.parseString a[0]}, #{$.parseString a[1]}) is #{a[2]}"

#parse short date
do ->
  divide()
  for a in [
    ['2012.12.21', '20121221']
    ['1999.1.1', '19990101']
    ['2050.2.28', '20500228']
  ]
    test $.parseShortDate($.timeStamp a[0]), a[1], "$.parseShortDate(#{a[0]}) is #{a[1]}"

#parse string
do ->
  divide()
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
    test $.parseString(a[0]), a[1], "$.parseString(#{$.parseString a[0]}) is #{a[1]}"

#parse pts
do ->
  divide()
  for a in [
    [0, '0']
    [100, '100']
    [1e3, '1,000']
    [1e4, '10,000']
    [1e5, '10万']
    [1234567, '123.4万']
  ]
    test $.parsePts(a[0]), a[1], "$.parsePts(#{$.parseString a[0]}) is #{a[1]}"

#parse json
do ->
  divide()
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
    test _.isEqual($.parseJson(a[0]), a[1]), true, "$.parseJson(#{$.parseString a[0]}) is #{a[1]}"

#promise
$.next ->

  divide()

  salt = _.now()

  #fail/reject
  a = $.Deferred()
  .fail (data) ->
    if salt != data
      $.info 'fail', 'fail/reject'
      return
    $.info 'success', 'fail/reject'
  $.next -> a.reject salt

  #done/resolve
  b = $.Deferred()
  .done (data) ->
    if salt != data
      $.info 'fail', 'done/resolve'
      return
    $.info 'success', 'done/resolve'
  $.next -> b.resolve salt

#ajax
$.next 500, ->

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

  divide()

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
do ->
  divide()
  msg = "There has got #{fails} fail(s)."
  msg = colors[if fails then 'red' else 'green'] msg
  $.info 'result', msg