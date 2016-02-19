_ = require 'lodash'
colors = require 'colors/safe'

module.exports = $ =
  version: '0.3.6'
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
  type = Object::toString.call(param).replace(/^\[object\s(.+)\]$/, '$1').toLowerCase()
  if type == 'uint8array'
    return 'buffer'
  type

#noop
$.noop = _.noop

#each
$.each = _.each
$.Callbacks = (options) ->
  options = $.extend {}, options

  res = {}
  status = res._status =
    fired: false
  list = res._list = []

  #method
  res.add = (args...) ->
    for fn in args when $.type(fn) == 'function'
      if options.unique
        if !res.has(fn)
          list.push fn
        continue
      list.push fn
    res

  res.remove = (fn) ->
    _.remove list, (_fn) -> _fn == fn
    res

  res.has = (fn) -> fn in list

  res.empty = ->
    list = []
    res

  res.fire = (args...) ->
    if options.once and status.fired
      return res

    for fn in list
      fn args...
    status.fired = true
    res

  res.fireWith = (context, args...) ->
    if options.once and status.fired
      return res

    for fn in list
      fn.apply context, args
    status.fired = true
    res

  res.fired = -> status.fired

  #return
  res
#deferred
$.Deferred = ->
  res = {}
  status = res._status =
    state: 'pending'
  list = res._list =
    done: $.Callbacks once: true
    fail: $.Callbacks once: true
    notify: $.Callbacks()

  #method

  #promise
  res.promise = (obj) ->
    if obj? then return $.extend obj, res
    res

  #state
  res.state = -> status.state

  #done, fail, notify
  for a in ['done', 'fail', 'notify']
    do (b = a) ->

  #each
  for a in [
    ['resolve', 'done', 'resolved']
    ['reject', 'fail', 'rejected']
    ['progress', 'notify']
  ]
    do (b = a) ->
      res[b[1]] = (callback) ->
        if $.type(callback) == 'function' then list[b[1]].add callback
        res

      fn = (type, args...) ->
        if b[2] then status.state = b[2]
        list[b[1]]['fire' + if type then 'With' else ''] args...
        res

      res[b[0]] = (args...) -> fn false, args...
      res[b[0] + 'With'] = (context, args...) -> fn true, context, args...

  #then & always
  res.then = (args...) -> res.done(args[0]).fail args[1]
  res.always = (callback) -> res.done(callback).fail callback

  #return
  res
#parseTime
$.parseTime = (param, future) ->
  $.parseTime.trans $.timeStamp(param), future

#trans
$.parseTime.trans = (t, future) ->

  dt = new Date t
  ts = dt.getTime()

  dtNow = new Date()
  tsNow = dtNow.getTime()

  tsDistance = tsNow - ts

  hrMin = dt.getHours() + '时' + ((if dt.getMinutes() < 10 then '0' else '')) + dt.getMinutes() + '分'
  longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin
  longLongAgo = dt.getFullYear() + '年' + longAgo

  #future
  i = 0
  if tsDistance < 0
    if !future then return '刚刚'
    i = 1
  if i then tsDistance = -tsDistance + 500

  #years ago
  if (tsDistance / 31536e6) | 0
    return longLongAgo

  #three days ago
  if (dayAgo = tsDistance / 864e5) > 3
    #if not same year
    if dt.getFullYear() != dtNow.getFullYear()
      return longLongAgo
    return longAgo

  #  if (dayAgo = (dtNow.getDay() - dt.getDay() + 7) % 7) > 2
  #    return longAgo

  #one day ago
  if dayAgo > 1
    return ['前天 ', '后天 '][i] + hrMin

  #12 hours ago
  if (hrAgo = tsDistance / 36e5) > 12
    return (if dt.getDay() != dtNow.getDay() then ['昨天 ', '明天 '][i] else '今天 ') + hrMin

  #hours ago
  if hrAgo = (tsDistance / 36e5 % 60) | 0
    return hrAgo + ['小时前', '小时后'][i]

  #minutes ago
  if minAgo = (tsDistance / 6e4 % 60) | 0
    return minAgo + ['分钟前', '分钟后'][i]

  #30 seconds ago
  if (secAgo = (tsDistance / 1e3 % 60) | 0) > 30
    return secAgo + ['秒前', '秒后'][i]

  #just now
  '刚刚'

#parseShortDate
$.parseShortDate = (param) ->
  date = if $.type(param) == 'date' then param else new Date param
  arr = [
    date.getFullYear()
    1 + date.getMonth()
    date.getDate()
  ]
  for a, i in arr
    arr[i] = $.parseString a
    if i and arr[i].length < 2
      arr[i] = '0' + arr[i]
  arr.join ''

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

  arr = ["[#{colors.gray t}]"]
  switch type
    when 'default' then null
    when 'success', 'done', 'ok' then arr.push "<#{colors.green type.toUpperCase()}>"
    when 'fail', 'error', 'fatal' then arr.push "<#{colors.red type.toUpperCase()}>"
    else arr.push "<#{colors.cyan type.toUpperCase()}>"
  arr.push msg

  $.log arr.join ' ' #log

  msg

#i
$.i = (msg) ->
  $.log colors.red msg
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

#shell
$.shell = (cmd, callback) ->
  fn = $.shell
  fn.platform or= (require 'os').platform()
  fn.exec or= (require 'child_process').exec
  fn.info or= (string) ->
    text = $.trim string
    if !text.length then return
    $.log text.replace(/\r/g, '\n').replace /\n{2,}/g, ''

  if $.type(cmd) == 'array'
    cmd = if fn.platform == 'win32' then cmd.join('&') else cmd.join('&&')
  $.info 'shell', colors.magenta cmd

  #execute
  child = fn.exec cmd
  child.stdout.on 'data', (data) -> fn.info data
  child.stderr.on 'data', (data) -> fn.info data
  child.on 'close', -> callback?()