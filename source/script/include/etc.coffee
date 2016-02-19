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