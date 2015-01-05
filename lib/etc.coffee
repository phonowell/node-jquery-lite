#log
$.log = console.log

#info
$.info = (p...) ->
  #param
  [type, text] = if p[1]? then [p[0], p[1]] else ['default', p[0]]
  #toString
  text = $.parseString text
  #check ::
  arr = text.split '::'
  if arr.length > 1
    type = arr[0]
    text = arr[1...].join '::'
  #check debug
  if type == 'debug' and !$.debug
    return
  #require colors
  c = require 'colors/safe'
  #type
  text = switch type
    when 'fatal'
      c.white.bgRed('[fatal]') + ' ' + c.white.bgRed text
    when 'error'
      c.red('[error]') + ' ' + c.red text
    when 'warn', 'warning'
      c.yellow('[warn]') + ' ' + c.yellow text
    when 'success'
      c.green('[success]') + ' ' + c.green text
    when 'info'
      c.cyan('[info]') + ' ' + text
    when 'debug'
      c.magenta('[debug]') + ' ' + c.magenta text
    else
      text
  $.log c.grey($.timeString()) + ' ' + text

#i
$.i = (text) ->
  if $.debug
    $.info 'debug', $.parseString text

#timeStamp
$.timeStamp = (param) ->
  #check param
  switch $.type p = param
    when 'number' then p
    when 'string'
      text = p
      #check string
      if text.search(/[\s\.\-\/]/) != -1
        #check :
        if text.search(/\:/) != -1
          #has got :, 2013.8.6 12:00
          a = text.split(' ')
          #check :
          if a[0].search(/\:/) == -1
            #2013.8.6 12:00
            b = a[0].replace(/[\-\/]/g, '.').split('.')
            c = a[1].split(':')
          else
            #12:00 2013.8.6
            b = a[1].replace(/[\-\/]/g, '.').split('.')
            c = a[0].split(':')
        else
          #has got no :, 2013.8.6
          b = text.replace(/[\-\/]/g, '.').split('.')
          c = [0, 0, 0]
        #trans arr into nums
        for i in [0..2]
          b[i] = b[i] | 0
          c[i] = (c[i] or 0) | 0
        d = new Date()
        d.setFullYear b[0], (b[1] - 1), b[2]
        d.setHours c[0], c[1], c[2]
        ((d.getTime() / 1e3) | 0) * 1e3
      else $.now()
    else $.now()

#delay
$.delay = (param...) ->
  #inner func
  func = delay: 200
  #check param
  switch param.length
    when 1
    #param - {object}
      $.extend func, param[0]
      func.name = '$.fn.info()'
    when 2
    #param - id, function
      func.id = param[0].toString()
      func.callback = param[1]
    when 3
    #param - id, delay, function
      func.id = param[0].toString()
      func.delay = param[1] | 0
      func.callback = param[2]
  #check param
  if func.id and func.delay >= 0 and func.callback
    #prepare
    c = $.delay.cache ?= {}
    c[func.id] ?=
      time: 0
      timer: null
    #check interval
    now = $.now()
    f = ->
      c[func.id].time = now
      func.callback?()
    if now - c[func.id].time > func.delay
      f()
    else
      clearTimeout c[func.id].timer
      c[func.id].timer = setTimeout f, func.delay

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

#mid
$.mid = -> Math.random().toString(36).substring 2

#time
$.timeString = (time) ->
  d = if time then new Date time else new Date()
  f = (n) ->
    if n < 10
      '0' + n
    else
      n
#  arr = [
#    [
#      1 + d.getMonth()
#      d.getDate()
#    ].join '.'
#    [
#      f d.getHours()
#      f d.getMinutes()
#      f d.getSeconds()
#    ].join ':'
#  ]
  arr = [
    f d.getHours()
    f d.getMinutes()
    f d.getSeconds()
  ]
  arr.join ':'