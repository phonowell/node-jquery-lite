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

$.timeStamp = (arg) ->

  type = $.type arg

  if type == 'number' then return _.floor arg, -3

  if type != 'string' then return _.floor _.now(), -3

  str = _.trim arg
  .replace /\s+/g, ' '
  .replace /[-|/]/g, '.'

  date = new Date()

  arr = str.split ' '

  b = arr[0].split '.'
  date.setFullYear b[0], (b[1] - 1), b[2]

  if !(a = arr[1])
    date.setHours 0, 0, 0, 0
  else
    a = a.split ':'
    date.setHours a[0], a[1], a[2] or 0, 0

  date.getTime()

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