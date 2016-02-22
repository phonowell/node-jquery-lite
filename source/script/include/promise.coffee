$.Deferred = ->
  res = {}
  status = res._status =
    state: 'pending'
    _arguments: null
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

  #each
  for _a in [
    ['resolve', 'done', 'resolved']
    ['reject', 'fail', 'rejected']
    ['progress', 'notify']
  ]
    do (a = _a) ->
      res[a[1]] = (callback) ->
        if $.type(callback) == 'function' then list[a[1]].add callback
        res

      fn = (type, args...) ->
        if a[2] then status.state = a[2]
        status._arguments = args
        list[a[1]]['fire' + if type then 'With' else ''] args...
        res

      res[a[0]] = (args...) -> fn false, args...
      res[a[0] + 'With'] = (context, args...) -> fn true, context, args...

  #then & always
  res.then = (args...) -> res.done(args[0]).fail args[1]
  res.always = (callback) -> res.done(callback).fail callback

  #return
  res

#0: pending, 1: resolved, 2: rejected
$.when = (args...) ->
  def = $.Deferred()

  parseArgs = (arr) -> if arr.length == 1 then arr[0] else arr

  list =
    state: []
    args: []

  for _arg, _i in args
    do (arg = _arg, i = _i) ->
      if !arg?._status?.state
        list.state.push 1
        list.args[i] = arg
        return

      state = arg._status.state

      if state == 'resolved'
        list.state.push 1
        list.args[i] = parseArgs arg._status._arguments
        return

      if state == 'rejected'
        list.state = null
        list.args = arg._status._arguments
        return

      list.state.push 0
      arg.done (p...) -> def.progress i, 1, p
      .fail (p...) -> def.reject p...

    if !list.state
      break

  if !list.state
    $.next -> def.reject.apply def, list.args
    return def.promise()

  if !(0 in list.state)
    $.next -> def.resolve.apply def, list.args
    return def.promise()

  def.notify (i, state, p) ->
    list.state[i] = state
    list.args[i] = parseArgs p

    if 0 in list.state
      return

    def.resolve.apply def, list.args

  def.promise()