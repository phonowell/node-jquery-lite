$ = require './index'
_ = $._

express = require 'express'
app = express()
bodyParser = require 'body-parser'

# function

$.next = (param...) ->
  [time, fn] = if !param[1] then [0, param[0]] else param

  if time
    setTimeout fn, time
    return

  process.nextTick fn

$.log = console.log

$.info = (args...) ->
  switch args.length
    when 1 then console.log args[0]
    when 2 then console.log "<#{args[0].toUpperCase()}> #{args[1]}"


$total = [0, 0]
$.test = (a, b, msg) ->
  $total[0]++
  if a == b
    $.info 'success', $.parseOK msg
  else
    $.info 'fail', $.parseOK msg, false
    $.log "# #{a} is not #{b}"
    $total[1]++

$.divide = (title) -> $.log "#{_.repeat '-', 16}#{if title then "> #{title}" else ''}"

$.parseOK = (msg, ok) ->
  if !~msg.search /\[is]/
    return msg
  if ok == false
    return msg.replace /\[is]/, 'is not'
  msg.replace /\[is]/, 'is'

$.parseString = (arg) -> new String arg

$subject = [
  1024 # number
  'hello world' # string
  true # boolean
  [1, 2, 3] # array
  {a: 1, b: 2} # object
  -> return null # function
  new Date() # date
  new Error('All Right') # error
  new Buffer('String') # buffer
  null # null
  undefined # undefined
  NaN # NaN
]

# version
do ->
  $.divide 'Version'
  version = '0.4.1'
  $.test $.version, version, "$.version [is] #{version}"

# $.Callbacks().add()
# $.Callbacks().disable()
# $.Callbacks().disabled()
# $.Callbacks().empty()
# $.Callbacks().fire()
# $.Callbacks().fired()
# $.Callbacks().fireWith()
# $.Callbacks().has()
# $.Callbacks().lock()
# $.Callbacks().locked()
# $.Callbacks().remove()
# $.Callbacks()
do ->
  $.divide '$.Callbacks()'

  # $.Callbacks().add()
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0..2]
      cb.add fn
    cb.fire()
    $.test a, 3, '$.Callbacks().add() [is] ok'

  # $.Callbacks().disable()
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0..2]
      cb.add fn
    cb.disable().fire()
    $.test a, 0, '$.Callbacks().disable() [is] ok'

  # $.Callbacks().disabled()
  do ->
    cb = $.Callbacks()
    cb.disable()
    $.test cb.disabled(), true, '$.Callbacks().disabled() [is] ok'

  # $.Callbacks().empty()
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0..2]
      cb.add fn
    cb.empty().fire()
    $.test a, 0, '$.Callbacks().empty() [is] ok'

  # $.Callbacks().fire()
  do ->
    cb = $.Callbacks()
    a = 0
    fn = (n) -> a += n
    for i in [0..2]
      cb.add fn
    cb.fire 2
    $.test a, 6, '$.Callbacks().fire() [is] ok'

  # $.Callbacks().fired()
  do ->
    cb = $.Callbacks()
    cb.fire()
    $.test cb.fired(), true, '$.Callbacks().fired() [is] ok'

  # $.Callbacks().fireWith()
  do ->
    cb = $.Callbacks()
    a = v: 0
    fn = (n, m) -> @v = @v + n * m
    for i in [0..2]
      cb.add fn
    cb.fireWith a, 2, 3
    $.test a.v, 18, '$.Callbacks().fireWith() [is] ok'

  # $.Callbacks().has()
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    _fn = -> a--
    for i in [0..2]
      cb.add fn
    cb.fire()
    $.test cb.has(fn) == true and cb.has(_fn) == false, true
    , '$.Callbacks().has() [is] ok'

  # $.Callbacks().lock()
  do ->
    cb = $.Callbacks()
    cb.lock()
    fn = -> null
    for i in [0..2]
      cb.add fn
    $.test cb.list.length, 0, '$.Callbacks().lock() [is] ok'

  # $.Callbacks().locked()
  do ->
    cb = $.Callbacks()
    cb.lock()
    $.test cb.locked(), true, '$.Callbacks().locked() [is] ok'

  # $.Callbacks().remove()
  do ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    _fn = -> a += 2
    for i in [0..2]
      cb.add fn
    cb.add _fn
    .remove fn
    .fire()
    $.test a, 2, '$.Callbacks().remove() [is] ok'

  # $.Callbacks()
  do ->
    # once: true
    do ->
      cb = $.Callbacks once: true
      a = 0
      fn = -> a++
      for i in [0..2]
        cb.add fn
      cb.fire().fire()
      $.test a, 3, '$.Callbacks({once: true}) [is] ok'
    # memory: true
    do ->
      cb = $.Callbacks memory: true
      a = 0
      fn = (n) -> a += n
      _fn = (n) -> a += n * 2
      cb.add fn
      .fire 2 # 0 + 2 = 2
      .add _fn # 2 + 2 * 2 = 6
      .fire 3 # 6 + 3 + 3 * 2 = 15
      $.test a, 15, '$.Callbacks({memory: true}) [is] ok'
    # unique: true
    do ->
      cb = $.Callbacks unique: true
      a = 0
      fn = -> a++
      for i in [0..2]
        cb.add fn
      cb.fire()
      $.test a, 1, '$.Callbacks({unique: true}) [is] ok'
    # stopOnFalse: true
    do ->
      cb = $.Callbacks stopOnFalse: true
      a = 0
      fn = -> a++
      _fn = ->
        a++
        false
      cb.add fn
      .add _fn
      .add fn
      .fire()
      $.test a, 2, '$.Callbacks({stopOnFalse: true}) [is] ok'

# $.Deferred().always()
# $.Deferred().done()
# $.Deferred().fail()
# $.Deferred().notify()
# $.Deferred().notifyWith()
# $.Deferred().progress()
# $.Deferred().promise()
# $.Deferred().reject()
# $.Deferred().rejectWith()
# $.Deferred().resolve()
# $.Deferred().resolveWith()
# $.Deferred().state()
# $.Deferred().then()
# $.Deferred()
# $.when()
$.next 100, ->
  $.divide '$.Deferred()'

  # $.Deferred().always()
  do ->
    def = $.Deferred()
    def.always (data) ->
      $.test data, 0, "$.Deferred().always() [is] ok(resolve)"
    $.next -> def.resolve 0
  do ->
    def = $.Deferred()
    def.always (data) ->
      $.test data, 1, "$.Deferred().always() [is] ok(reject)"
    $.next -> def.reject 1

  # $.Deferred().done()
  do ->
    def = $.Deferred()
    def.done (data) ->
      $.test data, 0, "$.Deferred().done() [is] ok"
    $.next -> def.resolve 0

  # $.Deferred().fail()
  do ->
    def = $.Deferred()
    def.fail (data) ->
      $.test data, 0, "$.Deferred().fail() [is] ok"
    $.next -> def.reject 0

  # $.Deferred().notify()
  do ->
    def = $.Deferred()
    def.progress (data) ->
      $.test data, 0, "$.Deferred().notify() [is] ok"
    $.next -> def.notify 0

  # $.Deferred().notifyWith()
  do ->
    def = $.Deferred()
    a = v: 0
    def.progress (data) ->
      @v += data
      $.test a.v, 2, "$.Deferred().notifyWith() [is] ok"
    $.next -> def.notifyWith a, 2

  # $.Deferred().progress()
  do ->
    def = $.Deferred()
    def.progress (data) ->
      $.test data, 0, "$.Deferred().progress() [is] ok"
    $.next -> def.notify 0

  # $.Deferred().promise()

  # $.Deferred().reject()
  do ->
    def = $.Deferred()
    def.fail (data) ->
      $.test data, 0, "$.Deferred().reject() [is] ok"
    $.next -> def.reject 0

  # $.Deferred().rejectWith()
  do ->
    def = $.Deferred()
    a = v: 0
    def.fail (data) ->
      @v += data
      $.test a.v, 2, "$.Deferred().rejectWith() [is] ok"
    $.next -> def.rejectWith a, 2

  # $.Deferred().resolve()
  do ->
    def = $.Deferred()
    def.done (data) ->
      $.test data, 0, "$.Deferred().resolve() [is] ok"
    $.next -> def.resolve 0

  # $.Deferred().resolveWith()
  do ->
    def = $.Deferred()
    a = v: 0
    def.done (data) ->
      @v += data
      $.test a.v, 2, "$.Deferred().resolveWith() [is] ok"
    $.next -> def.resolveWith a, 2

  # $.Deferred().state()
  do ->
    def = $.Deferred()
    $.test def.state(), 'pending', '$.Deferred().state() [is] ok(pending)'
  do ->
    def = $.Deferred()
    def.done ->
      $.test def.state(), 'resolved', '$.Deferred().state() [is] ok(resolved)'
    $.next -> def.resolve()
  do ->
    def = $.Deferred()
    def.fail -> $.test def.state(), 'rejected', '$.Deferred().state() [is] ok(rejected)'
    $.next -> def.reject()

  # $.Deferred().then()
  do ->
    def = $.Deferred()
    fnDone = (data) ->
      $.test data, 0, '$.Deferred().then() [is] ok(resolve)'
    fnFail = -> null
    def.then fnDone, fnFail
    $.next -> def.resolve 0
  do ->
    def = $.Deferred()
    fnDone = -> null
    fnFail = (data) ->
      $.test data, 0, '$.Deferred().then() [is] ok(reject)'
    def.then fnDone, fnFail
    $.next -> def.reject 0

# $.each()

# $.extend()

# $.get()

# $.noop()

# $.now()

# $.param()

# $.post()

# $.serialize()
do ->
  $.divide '$.serialize()'

  for a, i in [
    {}
    {}
    {}
    {}
    {a: 1, b: 2}
    {}
    {}
    {}
    {}
    {}
    {}
    {}
  ]
    $.test _.isEqual($.serialize($subject[i]), a), true
    , "$.serialize(#{$.parseString $subject[i]}) [is] #{$.parseString a}"

  a = '?a=1&b=2&c=3&d=4'
  b =
    a: '1'
    b: '2'
    c: '3'
    d: '4'
  $.test _.isEqual($.serialize(a), b), true
  , "$.serialize(#{$.parseString a}) [is] #{$.parseString b}"

# $.trim()

# $.type()
do ->
  $.divide '$.type()'
  for a, i in [
    'number'
    'string'
    'boolean'
    'array'
    'object'
    'function'
    'date'
    'error'
    'buffer'
    'null'
    'undefined'
    'number'
  ]
    $.test $.type($subject[i]), a
    , "$.type(#{$.parseString $subject[i]}) [is] #{$.parseString a}"

# $.when()
$.next 200, ->
  $.divide '$.when()'

  # resolve
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
        $.test res, true, "$.when() [is] ok(resolve - #{i}/#{count})"

      a.resolve 0
      c.resolve 3, 4, 5

  # reject
  do ->
    index = 0
    count = 3

    do (i = ++index) ->
      a = $.Deferred()
      $.when a
      .fail (args...) ->
        res = true
        res = res and args[0] == 1 and args[1] == 2
        $.test res, true, "$.when() [is] ok(reject - #{i}/#{count})"
      a.reject 1, 2

    do (i = ++index) ->
      a = $.Deferred()
      b = $.Deferred()
      $.when a, b
      .fail (args...) ->
        res = true
        res = res and args[0] == 1 and args[1] == 2
        $.test res, true, "$.when() [is] ok(reject - #{i}/#{count})"
      a.resolve()
      b.reject 1, 2

    do (i = ++index) ->
      a = $.Deferred().reject 1, 2
      $.when a
      .fail (args...) ->
        res = true
        res = res and args[0] == 1 and args[1] == 2
        $.test res, true, "$.when() [is] ok(reject - #{i}/#{count})"

# ajax
$.next 300, ->
  $.divide 'Ajax'

  # server
  app.use bodyParser.urlencoded extended: true

  # route
  app.get '/ping', (req, res) -> res.send req.query.salt
  app.post '/ping', (req, res) -> res.send req.body.salt
  app.get '/json', (req, res) -> res.json value: req.query.salt
  app.post '/json', (req, res) -> res.json value: req.body.salt

  app.listen port = 9453
  base = "http://localhost:#{port}"

  salt = _.now()

  # get
  $.when $.get("#{base}/ping", salt: salt), $.get("#{base}/json", salt: salt)
  .always (data...) ->
    res = parseInt(data[0]) == parseInt(data[1].value) == salt
    $.test res, true, '$.get() [is] ok'

  # post
  $.when $.post("#{base}/ping", salt: salt), $.post("#{base}/json", salt: salt)
  .always (data...) ->
    res = parseInt(data[0]) == parseInt(data[1].value) == salt
    $.test res, true, '$.post() [is] ok'

# result
$.next 500, ->
  $.divide 'Result'
  msg = "There has got #{$total[1]} fail(s) from #{$total[0]} test(s)."
  $.info 'result', msg

  $.next 500, -> process.exit()