$ = require './../index'
_ = $._

assert = require 'assert'
check = assert.equal
checkDeep = assert.deepEqual

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
  VERSION = '0.6.0'
  it "$.version is #{VERSION}", ->
    check $.VERSION, VERSION

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

# $.each()

# $.extend()

# $.noop()

# $.now()

# $.param()

describe '$.parseJSON()', ->

  _.each $SUBJECT, (a, i) ->
    p = $SUBJECT[i]
    type = $.type p

    if type == 'number' and _.isNaN p
      # NaN
      it 'NaN', -> check _.isEqual($.parseJSON(p), a), true
      return

    it type, -> checkDeep $.parseJSON(p), a

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