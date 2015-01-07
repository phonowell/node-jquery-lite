#$
require './index'

#test
test = (bool, str) -> $.info (if bool then 'success' else 'error'), str

#describe
describe = (title, fn) ->
  #info
  $.log ''
  $.info 'info', title
  #callback
  fn?()

#$
describe '$', ->
  #$
  test $, '$ is ok'
  test $.type($) == 'object', '$ is an object'
  test $.type($.version) == 'string', '$.version is a string(' + $.version + ')'

  #error
  describe 'error', ->
    #try
    test $.try, '$.try is ok'

  #basic
  describe 'basic', ->
    #extend
    describe '$.extend', ->
      test $.parseString($.extend({}, {a: 1})) == $.parseString({a: 1}), '$.parseString($.extend({}, {a: 1})) == $.parseString({a: 1})'
      test $.parseString($.extend({a: 1}, {b: 2})) == $.parseString({a: 1, b: 2}), '$.parseString($.extend({a: 1}, {b: 2})) == $.parseString({a: 1, b: 2})'

    #type
    describe '$.type', ->
      test $.type(false) == 'boolean', "$.type(false) == 'boolean'"
      test $.type('123') == 'string', "$.type('123') == 'string'"
      test $.type(123) == 'number', "$.type(123) == 'number'"
      test $.type({}) == 'object', "$.type({}) == 'object'"
      test $.type([]) == 'array', "$.type([]) == 'array'"
      test $.type(->) == 'function', "$.type(->) == 'function'"
      test $.type(new Buffer 'buffer') == 'buffer', "$.type(new Buffer 'buffer') == 'buffer'"
      test $.type(null) == 'null', "$.type(null) == 'null'"
      test $.type(undefined) == 'undefined', "$.type(undefined) == 'undefined'"
      test $.type(NaN) == 'NaN', "$.type(NaN) == 'NaN'"

    #param
    describe '$.param', ->
      test $.param({a: 1, b: 2}) == 'a=1&b=2', "$.param({a: 1, b: 2}) == 'a=1&b=2'"

    #trim
    describe '$.trim', ->
      test $.trim(' trim test  ') == 'trim test', "$.trim(' trim test  ') == 'trim test'"

    #now
    describe '$.now', ->
      test $.now == Date.now, '$.now == Date.now'

    #callbacks
    describe '$.Callbacks', ->
      cb = $.Callbacks()
      i = 0
      f = -> i++
      e = -> i--
      test cb.add and cb.remove and cb.has and cb.empty and cb.fire and cb.fired, 'has got methods: .add(), .remove(), .has(), .empty(), .fire() and .fired()'
      #add
      test cb.list.length == 0, '.list length is 0, before .add()'
      cb.add f
      cb.add f
      test cb.list.length == 2, '.add() is ok'
      #remove
      cb.remove f
      test cb.list.length == 1, '.remove() is ok'
      #has
      test cb.has(f) and !cb.has(e), '.has() is ok'
      #empty
      cb.empty()
      test cb.list.length == 0, '.empty() is ok'
      #fired
      test cb.fired() == false, '.fired() returns false, before .fire()'
      #fire
      cb.add f
      .fire()
      test i == 1, '.fire() is ok'
      #fired
      test cb.fired() == true, '.fired() is ok'

  #parse
  describe 'parse', ->
    #parseTime
    describe '$.parseTime', ->
      test $.parseTime($.now()) == '刚刚', "$.parseTime($.now()) == '刚刚'"
      test $.parseTime($.timeStamp($.now() - 5e3)) == '5秒前', "$.parseTime($.timeStamp($.now() - 5e3)) == '5秒前'"
      test $.parseTime($.timeStamp($.now() - 3e5)) == '5分钟前', "$.parseTime($.timeStamp($.now() - 3e5)) == '5分钟前'"
      test $.parseTime($.timeStamp($.now() - 36e5)) == '1小时前', "$.parseTime($.timeStamp($.now() - 36e5)) == '1小时前'"

    #parseString
    describe '$.parseString', ->
      test $.parseString('123') == '123', "$.parseString('123') == '123'"

  #ajax
  describe 'ajax', ->

    #promise
  describe 'promise', ->

    #etc
  describe 'etc', ->
    #log
    describe '$.log', ->
      test $.log == console.log, '$.log == console.log'

    #info
    describe '$.info', ->
      test $.info, '$.info is ok'

    #i
    describe '$.i', ->
      test $.i, '$.i is ok'

    #timeStamp
    describe '$.timeStamp', ->
      test ($.timeStamp $.now()) == $.now(), '($.timeStamp $.now()) == $.now()'
      test ($.type $.timeStamp '2012.12.21') == 'number', "($.type $.timeStamp '2012.12.21') == 'number'"
      test ($.type $.timeStamp '1997.7.1 19:00') == 'number', "($.type $.timeStamp '1997.7.1 19:00') == 'number'"

    #delay
    describe '$.delay', ->
      test 1, 'not ready yet'

    #rnd
    describe '$.rnd', ->
      test ($.type $.rnd()) == 'number', "($.type $.rnd()) == 'number'"

    #mid
    describe '$.mid', ->
      test ($.type $.mid()) == 'string', "($.type $.mid()) == 'string'"