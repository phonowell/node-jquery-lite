_ = require 'lodash'

module.exports = $ =
  version: '0.3.2'
  startTime: _.now()
#require
domain = require 'domain'

#uncaughtException
process.on 'uncaughtException', (err) ->
  $.info 'fatal', err
  $.log err.stack

#try
$.try = (param...) ->
  p = param

  res =
    _domain: domain.create()

  res.try = (fn) ->
    $.next -> res._domain.run fn
    res

  res.catch = (fn) ->
    res._catch = fn
    res

  res._domain.on 'error', (err) ->
    $.info 'error', err
    res._catch? err

  #check param
  if ($.type p[0]) == 'function'
    res.try p[0]
  if ($.type p[1]) == 'function'
    res.catch p[1]

  res
#extend
$.extend = _.extend

#param
$.param = (require 'querystring').stringify

#trim
$.trim = _.trim

#now
$.now = _.now

#type
$.type = (param) ->
  p = param
  t = typeof p
  switch t
    when 'object'
      if p
        #if array
        if toString.call(p) == '[object Array]'
          return 'array'
        #if date
        if toString.call(p) == '[object Date]'
          return 'date'
        #if error
        if toString.call(p) == '[object Error]'
          return 'error'
        #if buffer
        if p.fill
          return 'buffer'
        #object
        'object'
      else
        #check if null
        if p == null
          return 'null'
        #undefined
        'undefined'
    when 'number'
      #check if NaN
      if p != +p
        return 'NaN'
      #number
      t
    else t

#noop
$.noop = _.noop
#callback
$.Callbacks = ->
  res =
    _status:
      fired: false
    _list: []

  list = res._list

  res.add = (param...) ->
    for fn in param
      list.push fn
    res

  res.remove = (fn) ->
    _.remove list, fn
    res

  res.has = (fn) -> fn in list

  res.empty = ->
    list = []
    res

  res.fire = (param...) ->
    for fn in list
      fn? param...

    res._status.fired = true

    res

  res.fired = -> res._status.fired

  res
#deferred
$.Deferred = ->
  res =
    _list:
      done: $.Callbacks()
      fail: $.Callbacks()

  list = res._list

  res.done = (callback) ->
    list.done.add callback
    res

  res.fail = (callback) ->
    list.fail.add callback
    res

  res.resolve = (param...) ->
    list.done.fire param...
    res

  res.reject = (param...) ->
    list.fail.fire param...
    res

  res
#parseTime
$.parseTime = (param) -> $.parseTime.trans $.timeStamp param
$.parseTime.trans = (t) ->
  dt = new Date t
  ts = dt.getTime()

  dtNow = new Date()
  tsNow = dtNow.getTime()

  tsDistance = tsNow - ts

  hrMin = dt.getHours() + '时' + ((if dt.getMinutes() < 10 then '0' else '')) + dt.getMinutes() + '分'
  longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin
  longLongAgo = dt.getFullYear() + '年' + longAgo

  #future
  if tsDistance < 0
    return '刚刚'

  #years ago
  if (tsDistance / 1000 / 60 / 60 / 24 / 365) | 0
    return longLongAgo

  #three days ago
  if (dayAgo = tsDistance / 1000 / 60 / 60 / 24) > 3
    #if not same year
    if dt.getFullYear() != dtNow.getFullYear()
      return longLongAgo
    return longAgo

  if (dayAgo = (dtNow.getDay() - dt.getDay() + 7) % 7) > 2
    return longAgo

  #one day ago
  if dayAgo > 1
    return '前天 ' + hrMin

  #12 hours ago
  if (hrAgo = tsDistance / 1000 / 60 / 60) > 12
    return (if dt.getDay() != dtNow.getDay() then '昨天 ' else '今天 ') + hrMin

  #hours ago
  if hrAgo = (tsDistance / 1000 / 60 / 60 % 60) | 0
    return hrAgo + '小时前'

  #minutes ago
  if minAgo = (tsDistance / 1000 / 60 % 60) | 0
    return minAgo + '分钟前'

  #30 seconds ago
  if (secAgo = (tsDistance / 1000 % 60) | 0) > 30
    return secAgo + '秒前'

  #just now
  '刚刚'

#parseString
$.parseString = (data) ->
  switch $.type d = data
    when 'string' then d
    when 'number' then d.toString()
    when 'array'
      (JSON.stringify _obj: d)
      .replace /\{(.*)\}/, '$1'
      .replace /"_obj":/, ''
    when 'object'then JSON.stringify d
    when 'boolean' then d.toString()
    when 'undefined' then 'undefined'
    when 'null' then 'null'
    else
      try
        d.toString()
      catch e
        ''

#parsePts
$.parsePts = (number) ->
  if (n = (number or 0) | 0) >= 1e5 then (((n * 0.001) | 0) / 10) + '万'
  else n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

#parseJson
$.parseJson = $.parseJSON = (data) ->
  d = data

  fn = (p) ->
    try
      res = eval "(" + p + ")"

      switch $.type res
        when 'object', 'array'
          res
        else
          null
    catch e
      null

  switch $.type d
    when 'string' then fn d
    when 'object' then d
    else null
request = require 'request'

parseType = (res) ->
  type = res.headers['content-type']

  if type and ~type.search /application\/json/
    return 'json'

  'text'

#get
$.get = (url, query) ->

  def = $.Deferred()

  request
    method: 'GET'
    url: url
    form: query
    gzip: true
  , (err, res, body) ->
    if err
      def.reject err
      return

    type = parseType res

    def.resolve if type == 'json' then $.parseJson(body) else body

  def

#post
$.post = (url, query) ->

  def = $.Deferred()

  request
    method: 'POST'
    url: url
    form: query
    gzip: true
  , (err, res, body) ->
    if err
      def.reject err
      return

    type = parseType res

    def.resolve if type == 'json' then $.parseJson(body) else body

  def
#next
$.next = (param...) ->
  [time, fn] = if !param[1] then [0, param[0]] else param

  if time
    setTimeout fn, time
    return

  process.nextTick fn

#log
$.log = console.log

#info
$.info = (param...) ->
  [type, msg] = if !param[1] then ['default', param[0]] else param

  #time
  d = new Date()
  t = ((if a < 10 then '0' + a else a) for a in [d.getHours(), d.getMinutes(), d.getSeconds()]).join ':'

  arr = ['[' + t + ']']
  if type != 'default' then arr.push '<' + type.toUpperCase() + '>'
  arr.push msg

  $.log arr.join ' ' #log

  msg

#i
$.i = (msg) ->
  $.log msg
  msg

#timeStamp
$.timeStamp = (param) ->
  #check param
  switch $.type p = param
    when 'number' then p
    when 'string'
      #check string
      if !~p.search /[\s\.\-\/]/
        return $.now()

      #check :
      if ~p.search /\:/
        #has got :, 2013.8.6 12:00
        a = p.split ' '
        #check :
        if !~a[0].search /\:/
          #2013.8.6 12:00
          b = a[0].replace(/[\-\/]/g, '.').split '.'
          c = a[1].split ':'
        else
          #12:00 2013.8.6
          b = a[1].replace(/[\-\/]/g, '.').split '.'
          c = a[0].split ':'
      else
        #has got no :, 2013.8.6
        b = p.replace(/[\-\/]/g, '.').split '.'
        c = [0, 0, 0]

      #trans arr into nums
      for i in [0..2]
        b[i] = parseInt b[i]
        c[i] = parseInt(c[i] or 0)
      d = new Date()
      d.setFullYear b[0], (b[1] - 1), b[2]
      d.setHours c[0], c[1], c[2]
      parseInt(d.getTime() / 1e3) * 1e3
    else $.now()

#rnd
$.rnd = (p...) ->
  r = Math.random()
  #check param
  switch p.length
    when 1
      #check type
      switch $.type p[0]
        #number
        when 'number'
          (r * p[0]) | 0
        #array
        when 'array'
          p[0][(r * p[0].length) | 0]
    when 2
      (p[0] + r * (p[1] - p[0])) | 0
    else (r * 2) | 0

#time
$.timeString = (time) ->
  d = if time then new Date time else new Date()

  fn = (n) -> if (n < 10) then '0' + n else n

  [
    fn d.getHours()
    fn d.getMinutes()
    fn d.getSeconds()
  ].join ':'