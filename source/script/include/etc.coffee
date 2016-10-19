# next
$.next = (param...) ->
  [time, fn] = if !param[1] then [0, param[0]] else param

  if time
    setTimeout fn, time
    return

  process.nextTick fn

# log
$.log = console.log

# info
$.info = (param...) ->
  [type, msg] = if !param[1] then ['default', param[0]] else param

  #time
  d = new Date()
  t = ((if a < 10 then '0' + a else a) for a in [d.getHours(), d.getMinutes(), d.getSeconds()]).join ':'

  arr = ["[#{t}]"]
  switch type
    when 'default' then null
    when 'success', 'done', 'ok' then arr.push "<#{type.toUpperCase()}>"
    when 'fail', 'error', 'fatal' then arr.push "<#{type.toUpperCase()}>"
    else arr.push "<#{type.toUpperCase()}>"
  arr.push msg

  $.log arr.join ' ' #log

  msg

# i
$.i = (msg) ->
  $.log msg
  msg

# timeStamp
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

# time
$.timeString = (time) ->
  d = if time then new Date time else new Date()

  fn = (n) -> if (n < 10) then '0' + n else n

  [
    fn d.getHours()
    fn d.getMinutes()
    fn d.getSeconds()
  ].join ':'

# shell
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
  $.info 'shell', cmd

  #execute
  child = fn.exec cmd
  child.stdout.on 'data', (data) -> fn.info data
  child.stderr.on 'data', (data) -> fn.info data
  child.on 'close', -> callback?()

# serialize
$.serialize = (string) ->
  switch $.type string
    when 'object' then string
    when 'string'
      if !~string.search /=/ then return {}
      res = {}
      for a in _.trim(string.replace /\?/g, '').split '&'
        b = a.split '='
        [key, value] = [_.trim(b[0]), _.trim b[1]]
        if key.length then res[key] = value
      res
    else {}