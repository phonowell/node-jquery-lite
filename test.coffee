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
    $.info 'success', parseOkay msg
  else
    $.info 'fail', parseOkay msg, false
    fails++

divide = (title) -> $.log colors.gray _.repeat('-', 16) + if title then '> ' + title or ''

parseOkay = (msg, okay) ->
  if !~msg.search /\[is]/
    return msg
  if okay == false
    return msg.replace /\[is]/, colors.red 'is not'
  msg.replace /\[is]/, colors.green 'is'

#version
do ->
  divide 'VERSION'
  a = '0.3.6'
  test $.version, a, '$.version [is] ' + a

#$.type()
do ->
  divide '$.type()'
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
    test $.type(a[0]), a[1], "$.type(#{$.parseString a[0]}) [is] #{a[1]}"

#$.parseTime()
do ->
  divide '$.parseTime()'
  for a in [
    #before
    [_.now(), undefined, '刚刚']
    [_.now() - 45e3, undefined, '45秒前']
    [_.now() - 6e4, undefined, '1分钟前']
    [_.now() - 36e5, undefined, '1小时前']
    ['2012.12.21 12:00', undefined, '2012年12月21日(星期五) 12时00分']
    #after
    [_.now() + 45e3, true, '45秒后']
    [_.now() + 6e4, true, '1分钟后']
    [_.now() + 36e5, true, '1小时后']
    ['2050.2.28', true, '2050年2月28日(星期一) 0时00分']
    #error
    [_.now() + 1e3, undefined, '刚刚']
    [_.now() - 45e3, true, '45秒前']
  ]
    #$.i $.parseTime a[0], a[1]
    test $.parseTime(a[0], a[1]), a[2], "$.parseTime(#{$.parseString a[0]}, #{$.parseString a[1]}) [is] #{a[2]}"

#$.parseShortDate()
do ->
  divide '$.parseShortDate()'
  for a in [
    ['2012.12.21', '20121221']
    ['1999.1.1', '19990101']
    ['2050.2.28', '20500228']
  ]
    test $.parseShortDate($.timeStamp a[0]), a[1], "$.parseShortDate(#{a[0]}) [is] #{a[1]}"

#$.parseString()
do ->
  divide '$.parseString()'
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
    test $.parseString(a[0]), a[1], "$.parseString(#{$.parseString a[0]}) [is] #{a[1]}"

#$.parsePts
do ->
  divide '$.parsePts()'
  for a in [
    [0, '0']
    [100, '100']
    [1e3, '1,000']
    [1e4, '10,000']
    [1e5, '10万']
    [1234567, '123.4万']
  ]
    test $.parsePts(a[0]), a[1], "$.parsePts(#{$.parseString a[0]}) [is] #{a[1]}"

#$.parseJson()
do ->
  divide '$.parseJson()'
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
    test _.isEqual($.parseJson(a[0]), a[1]), true, "$.parseJson(#{$.parseString a[0]}) [is] #{a[1]}"

#$.Callbacks()
do ->
  divide '$.Callbacks()'

  #add
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0...3]
      cb.add fn
    cb.add -> test a, 3, '$.Callbacks().add() [is] okay.'
    cb.fire()

  #add with options.unique
  do ->
    cb = $.Callbacks unique: true
    a = 0
    fn = -> a++
    for i in [0...3]
      cb.add fn
    cb.add -> test a, 1, '$.Callbacks({unique: true}).add() [is] okay.'
    cb.fire()

  #remove
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0...3]
      cb.add fn
    cb.remove fn
    cb.add -> test a, 0, '$.Callbacks().remove() [is] okay.'
    cb.fire()

  #has
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0...3]
      cb.add fn
    cb.add -> test cb.has(fn) == true and cb.has(-> a--) == false, true, '$.Callbacks().has() [is] okay.'
    cb.fire()

  #empty
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0...3]
      cb.add fn
    cb.empty()
    cb.add -> test a, 0, '$.Callbacks().empty() [is] okay.'
    cb.fire()

  #fireWith
  do ->
    cb = $.Callbacks()
    a = v: 0
    fn = (n) -> @v = @v + n
    for i in [0...3]
      cb.add fn
    cb.add -> test a.v, 6, '$.Callbacks().fireWith() [is] okay.'
    cb.fireWith a, 2

  #fire
  do ->
    cb = $.Callbacks()
    a = 0
    fn = (n) -> a = a + n
    for i in [0...3]
      cb.add fn
    cb.add -> test a, 6, '$.Callbacks().fire() [is] okay.'
    cb.fire 2

#promise
$.next ->
  divide 'Promise'

  salt = _.now()

  #fail/reject
  a = $.Deferred()
  .fail (data) ->
    if salt != data
      $.info 'fail', parseOkay 'fail/reject [is] okay.', false
      return
    $.info 'success', parseOkay 'fail/reject [is] okay.'
  $.next -> a.reject salt

  #done/resolve
  b = $.Deferred()
  .done (data) ->
    if salt != data
      $.info 'fail', parseOkay 'done/resolve [is] okay.', false
      return
    $.info 'success', parseOkay 'done/resolve [is] okay.'
  $.next -> b.resolve salt

#ajax
$.next 500, ->
  divide 'Ajax'

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

  salt = _.now()

  #ping
  $.get base + '/ping', salt: salt
  .fail (data) -> $.info 'fail', '$.get("/ping") [is] okay: ' + data, false
  .done (data) ->
    if salt != parseInt data
      $.info 'fail', parseOkay '$.get("/ping") [is] okay: ' + data, false
      return
    $.info 'success', parseOkay '$.get("/ping") [is] okay.'

  #json
  $.get base + '/json', salt: salt
  .fail (data) -> $.info 'fail', parseOkay '$.get("/json") [is] okay: ' + data, false
  .done (data) ->
    if salt != data.salt
      $.info 'fail', parseOkay '$.get("/json") [is] okay: ' + data, false
      return
    $.info 'success', parseOkay '$.get("/json") [is] okay.'

  #ping
  $.post base + '/ping', salt: salt
  .fail (data) -> $.info 'fail', parseOkay '$.post("/ping") [is] okay: ' + data, false
  .done (data) ->
    if salt != parseInt data
      $.info 'fail', parseOkay '$.post("/ping") [is] okay: ' + data, false
      return
    $.info 'success', parseOkay '$.post("/ping") [is] okay.'

  #json
  $.post base + '/json', salt: salt
  .fail (data) -> $.info 'fail', parseOkay '$.post("/json") [is] okay: ' + $.parseString(data), false
  .done (data) ->
    if salt != data.salt
      $.info 'fail', parseOkay '$.post("/json") [is] okay: ' + $.parseString(data), false
      return
    $.info 'success', parseOkay '$.post("/json") [is] okay.'

  $.next 1e3, -> process.exit()

#final
do ->
  divide 'FINAL'
  msg = "There has got #{fails} fail(s)."
  msg = colors[if fails then 'red' else 'green'] msg
  $.info 'result', msg