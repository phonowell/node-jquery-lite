_ = require 'lodash'
$ = require './index'

express = require 'express'
app = express()
bodyParser = require 'body-parser'

colors = require 'colors/safe'

#function
total = [0, 0]
test = (a, b, msg) ->
  total[0]++
  if a == b
    $.info 'success', parseOkay msg
  else
    $.info 'fail', parseOkay msg, false
    total[1]++

divide = (title) -> $.log colors.gray _.repeat('-', 16) + if title then '> ' + title or ''

parseOkay = (msg, okay) ->
  if !~msg.search /\[is]/
    return msg
  if okay == false
    return msg.replace /\[is]/, colors.red 'is not'
  msg.replace /\[is]/, colors.green 'is'

#version
do ->
  divide 'Version'
  a = '0.3.11'
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
  arr = [
    new Date()
    new Error 'error'
    new Buffer 'buffer'
    null
    undefined
    NaN
  ]
  for a in [
    [1096, 1096]
    ['hello world', 'hello world']
    [true, true]
    ['[1, 2, 3]', [1,2,3]]
    ['{"a":1,"b":2}', {a: 1, b: 2}]
    [arr[0], arr[0]]
    [arr[1], arr[1]]
    [arr[2], arr[2]]
    [arr[3], arr[3]]
    [arr[4], arr[4]]
    [arr[5], arr[5]]
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

  #fire
  do ->
    cb = $.Callbacks()
    a = 0
    fn = (n) -> a = a + n
    for i in [0...3]
      cb.add fn
    cb.add -> test a, 6, '$.Callbacks().fire() [is] okay.'
    cb.fire 2

  #fire with once:true
  do ->
    cb = $.Callbacks once: true
    a = 0
    fn = -> a++
    for i in [0...3]
      cb.add fn
    cb.add -> test a, 3, '$.Callbacks({once: true}).fire() [is] okay.'
    cb.fire()
    cb.fire()

  #fireWith
  do ->
    cb = $.Callbacks()
    a = v: 0
    fn = (n, m) -> @v = @v + n * m
    for i in [0...3]
      cb.add fn
    cb.add -> test a.v, 18, '$.Callbacks().fireWith() [is] okay.'
    cb.fireWith a, 2, 3

#$.Deferred()
do ->
  divide '$.Deferred()'

  #state
  do ->
    def = $.Deferred()
    test def.state(), 'pending', "$.Deferred().state() [is] okay(#{colors.magenta 'pending'})."

  for a in [
    ['resolve', 'done', 'resolved']
    ['reject', 'fail', 'rejected']
    ['progress', 'notify']
  ]
    do (b = a) ->
      #done, fail & notify
      do ->
        def = $.Deferred()
        def[b[1]] (data) -> test data, 0, "$.Deferred().#{b[1]}() [is] okay."
        $.next -> def[b[0]] 0

      #resolveWith, rejectWith & progressWith
      do ->
        def = $.Deferred()
        def[b[1]] (args...) -> test @v, args[0] * args[1], "$.Deferred().#{b[0]}With() [is] okay."
        $.next -> def[b[0] + 'With'] {v: 6}, 2, 3

      if b[0] == 'progress' then return

      #state
      do ->
        def = $.Deferred()
        def[b[1]] -> test def.state(), b[2], "$.Deferred().state() [is] okay(#{colors.magenta b[2]})."
        def[b[0]]()

      #then
      do ->
        def = $.Deferred()
        def.then ((data) -> test data, 0, "$.Deferred().then() [is] okay(#{colors.magenta 'resolve'}).")
        , (data) -> test data, 0, "$.Deferred().then() [is] okay(#{colors.magenta 'reject'})."
        $.next -> def[b[0]] 0

      #always
      do ->
        def = $.Deferred()
        def.always (data) -> test data, 0, "$.Deferred().always() [is] okay(#{colors.magenta b[0]})."
        $.next -> def[b[0]] 0

#$.when()
$.next 100, ->
  divide '$.when()'

  #resolve
  do ->
    index = 0
    count = 2

    do (i = ++index) ->
      a = $.Deferred()
      b = [1, 2]
      c = $.Deferred()
      d = $.Deferred().resolve 'a', 'b'

      $.when a, b, c, d
      .done (args...) ->
        res = true
        res = res and args[0] == 0
        res = res and args[1][0] == 1 and args[1][1] == 2
        res = res and args[2][0] == 3 and args[2][1] == 4 and args[2][2] == 5
        res = res and args[3][0] == 'a' and args[3][1] == 'b'
        test res, true, "$.when() [is] okay(#{colors.magenta "resolve - #{i}/#{count}"})."

      a.resolve 0
      c.resolve 3, 4, 5

  #reject
  do ->
    index = 0
    count = 3

    do (i = ++index) ->
      a = $.Deferred()
      $.when a
      .fail (args...) ->
        res = true
        res = res and args[0] == 1 and args[1] == 2
        test res, true, "$.when() [is] okay(#{colors.magenta "reject - #{i}/#{count}"})."
      a.reject 1, 2

    do (i = ++index) ->
      a = $.Deferred()
      b = $.Deferred()
      $.when a, b
      .fail (args...) ->
        res = true
        res = res and args[0] == 1 and args[1] == 2
        test res, true, "$.when() [is] okay(#{colors.magenta "reject - #{i}/#{count}"})."
      a.resolve()
      b.reject 1, 2

    do (i = ++index) ->
      a = $.Deferred().reject 1, 2
      $.when a
      .fail (args...) ->
        res = true
        res = res and args[0] == 1 and args[1] == 2
        test res, true, "$.when() [is] okay(#{colors.magenta "reject - #{i}/#{count}"})."

#ajax
$.next 200, ->
  divide 'Ajax'

  #server
  app.use bodyParser.urlencoded extended: true

  #route
  app.get '/ping', (req, res) -> res.send req.body.salt
  app.post '/ping', (req, res) -> res.send req.body.salt
  app.get '/json', (req, res) -> res.json value: req.body.salt
  app.post '/json', (req, res) -> res.json value: req.body.salt

  app.listen port = 9453
  base = 'http://localhost:' + port

  salt = _.now()

  #get
  $.when $.get(base + '/ping', salt: salt), $.get(base + '/json', salt: salt)
  .always (data...) ->
    res = parseInt(data[0]) == parseInt(data[1].value) == salt
    test res, true, '$.get() [is] okay.'

  #post
  $.when $.post(base + '/ping', salt: salt), $.post(base + '/json', salt: salt)
  .always (data...) ->
    res = parseInt(data[0]) == parseInt(data[1].value) == salt
    test res, true, '$.post() [is] okay.'

#result
$.next 500, ->
  divide 'Result'
  msg = "There has got #{total[1]} fail(s) from #{total[0]} test(s)."
  msg = colors[if total[1] then 'red' else 'green'] msg
  $.info 'result', msg

  $.next 500, -> process.exit()