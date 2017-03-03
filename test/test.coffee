$ = require './../index'
_ = $._

assert = require 'assert'

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

$.parseString = (arg) -> new String arg

# test function

check = assert.equal
checkDeep = assert.deepEqual

$SUBJECT = [
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

describe '$.version', ->
  VERSION = '0.5.0'
  it "$.version is #{VERSION}", ->
    check $.version, VERSION

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

describe '$.Callbacks()', ->

  it '$.Callbacks().add()', ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0..2]
      cb.add fn
    cb.fire()

    check a, 3
      
  it '$.Callbacks().disable()', ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0..2]
      cb.add fn
    cb.disable().fire()

    check a, 0

  it '$.Callbacks().disabled()', ->
    cb = $.Callbacks()
    cb.disable()

    check cb.disabled(), true

  it '$.Callbacks().empty()', ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    for i in [0..2]
      cb.add fn
    cb.empty().fire()

    check a, 0

  it '$.Callbacks().fire()', ->
    cb = $.Callbacks()
    a = 0
    fn = (n) -> a += n
    for i in [0..2]
      cb.add fn
    cb.fire 2

    check a, 6

  it '$.Callbacks().fired()', ->
    cb = $.Callbacks()
    cb.fire()

    check cb.fired(), true

  it '$.Callbacks().fireWith()', ->
    cb = $.Callbacks()
    a = v: 0
    fn = (n, m) -> @v = @v + n * m
    for i in [0..2]
      cb.add fn
    cb.fireWith a, 2, 3

    check a.v, 18

  it '$.Callbacks().has()', ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    _fn = -> a--
    for i in [0..2]
      cb.add fn
    cb.fire()

    check cb.has(fn), true
    check cb.has(_fn), false

  it '$.Callbacks().lock()', ->
    cb = $.Callbacks()
    cb.lock()
    fn = -> null
    for i in [0..2]
      cb.add fn

    check cb.list.length, 0

  it '$.Callbacks().locked()', ->
    cb = $.Callbacks()
    cb.lock()

    check cb.locked(), true

  it '$.Callbacks().remove()', ->
    cb = $.Callbacks()
    a = 0
    fn = -> a++
    _fn = -> a += 2
    for i in [0..2]
      cb.add fn
    cb.add _fn
    .remove fn
    .fire()

    check a, 2

  describe '$.Callbacks()', ->

    it '$.Callbacks({once: true})', ->
      cb = $.Callbacks once: true
      a = 0
      fn = -> a++
      for i in [0..2]
        cb.add fn
      cb.fire().fire()

      check a, 3

    it '$.Callbacks({memory: true})', ->
      cb = $.Callbacks memory: true
      a = 0
      fn = (n) -> a += n
      _fn = (n) -> a += n * 2
      cb.add fn
      .fire 2 # 0 + 2 = 2
      .add _fn # 2 + 2 * 2 = 6
      .fire 3 # 6 + 3 + 3 * 2 = 15

      check a, 15

    it '$.Callbacks({unique: true})', ->
      cb = $.Callbacks unique: true
      a = 0
      fn = -> a++
      for i in [0..2]
        cb.add fn
      cb.fire()

      check a, 1

    it '$.Callbacks({stopOnFalse: true})', ->
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

      check a, 2

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

describe '$.Deferred()', ->

  describe '$.Deferred().always()', ->

    it 'resolve', ->
      def = $.Deferred()
      def.always (data) -> check data, 0,
      $.next -> def.resolve 0
    it 'reject', ->
      def = $.Deferred()
      def.always (data) -> check data, 1
      $.next -> def.reject 1

  it '$.Deferred().done()', ->
    def = $.Deferred()
    def.done (data) -> check data, 0
    $.next -> def.resolve 0

  it '$.Deferred().fail()', ->
    def = $.Deferred()
    def.fail (data) -> check data, 0
    $.next -> def.reject 0

  it '$.Deferred().notify()', ->
    def = $.Deferred()
    def.progress (data) -> check data, 0
    $.next -> def.notify 0

  it '$.Deferred().notifyWith()', ->
    def = $.Deferred()
    a = v: 0
    def.progress (data) ->
      @v += data
      check a.v, 2
    $.next -> def.notifyWith a, 2

  it '$.Deferred().progress()', ->
    def = $.Deferred()
    def.progress (data) -> check data, 0
    $.next -> def.notify 0

  # $.Deferred().promise()

  it '$.Deferred().reject()', ->
    def = $.Deferred()
    def.fail (data) -> check data, 0
    $.next -> def.reject 0

  it '$.Deferred().rejectWith()', ->
    def = $.Deferred()
    a = v: 0
    def.fail (data) ->
      @v += data
      check a.v, 2
    $.next -> def.rejectWith a, 2

  it '$.Deferred().resolve()', ->
    def = $.Deferred()
    def.done (data) -> check data, 0
    $.next -> def.resolve 0

  it '$.Deferred().resolveWith()', ->
    def = $.Deferred()
    a = v: 0
    def.done (data) ->
      @v += data
      check a.v, 2
    $.next -> def.resolveWith a, 2

  describe '$.Deferred().state()', ->

    it 'pending', ->
      def = $.Deferred()
      check def.state(), 'pending'

    it 'resolved', ->
      def = $.Deferred()
      def.done -> check def.state(), 'resolved'
      $.next -> def.resolve()

    it 'rejected', ->
      def = $.Deferred()
      def.fail -> check def.state(), 'rejected'
      $.next -> def.reject()

  describe '$.Deferred().then()', ->

    it 'resolve', ->
      def = $.Deferred()
      fnDone = (data) -> check data, 0
      fnFail = -> null
      def.then fnDone, fnFail
      $.next -> def.resolve 0

    it 'reject', ->
      def = $.Deferred()
      fnDone = -> null
      fnFail = (data) -> check data, 0
      def.then fnDone, fnFail
      $.next -> def.reject 0

# $.each()

# $.extend()

# $.get()

# $.noop()

# $.now()

# $.param()

# $.post()

describe '$.serialize()', ->

  LIST = [
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
  _.each LIST, (a, i) ->
    p = $SUBJECT[i]
    type = $.type p
    if type == 'number' and _.isNaN p then type = 'NaN'

    it type, -> checkDeep $.serialize(p), a

  it 'params', ->
    a = '?a=1&b=2&c=3&d=4'
    b =
      a: '1'
      b: '2'
      c: '3'
      d: '4'

    checkDeep $.serialize(a), b

# $.trim()

describe '$.type()', ->
  LIST = [
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
  _.each LIST, (a, i) ->
    it a, -> check $.type($SUBJECT[i]), a

describe '$.when()', ->

  it 'resolve', (done) ->

    a = $.Deferred()
    b = [1, 2]
    c = $.Deferred()
    d = $.Deferred().resolve 'a', 'b'

    $.when a, b, c, d
    .done (args...) ->
      # a
      check args[0], 0

      # b
      check args[1][0], 1
      check args[1][1], 2

      # c
      check args[2][0], 3
      check args[2][1], 4
      check args[2][2], 5

      # d
      check args[3][0], 'a'
      check args[3][1], 'b'

      done()

    a.resolve 0
    c.resolve 3, 4, 5

  describe 'reject', ->

    it 'case 1', (done) ->
      a = $.Deferred()

      $.when a
      .fail (args...) ->
        check args[0], 1
        check args[1], 2
        done()

      a.reject 1, 2

    it 'case 2', (done) ->
      a = $.Deferred()
      b = $.Deferred()

      $.when a, b
      .fail (args...) ->
        check args[0], 1
        check args[1], 2
        done()

      a.resolve()
      b.reject 1, 2

    it 'case 3', (done) ->
      a = $.Deferred().reject 1, 2

      $.when a
      .fail (args...) ->
        check args[0], 1
        check args[1], 2
        done()

describe 'ajax', ->

  app.use bodyParser.urlencoded extended: true

  app.get '/ping', (req, res) -> res.send req.query.salt
  app.post '/ping', (req, res) -> res.send req.body.salt

  app.get '/json', (req, res) -> res.json value: req.query.salt
  app.post '/json', (req, res) -> res.json value: req.body.salt

  app.listen port = 9453
  base = "http://localhost:#{port}"

  salt = _.now()

  it '$.get()', ->

    list = []
    list.push $.get "#{base}/ping", {salt}
    list.push $.get "#{base}/json", {salt}

    $.when.apply $, list
    .done (data...) ->
      a = parseInt data[0]
      b = parseInt data[1].value
      check a, salt
      check b, salt

  it '$.post()', ->

    list = []
    list.push $.post "#{base}/ping", {salt}
    list.push $.post "#{base}/json", {salt}

    $.when.apply $, list
    .done (data...) ->
      a = parseInt data[0]
      b = parseInt data[1].value
      check a, salt
      check b, salt