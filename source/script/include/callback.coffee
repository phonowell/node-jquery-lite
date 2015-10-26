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
    for f, i in list when f == fn
      list.splice i, 1
      break
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