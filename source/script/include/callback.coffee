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

  res.fireWith = (context, args...) ->
    for fn in list
      fn.apply context, args
    status.fired = true
    res

  res.fire = (args...) ->
    for fn in list
      fn args...
    status.fired = true
    res

  res.fired = -> status.fired

  #return
  res