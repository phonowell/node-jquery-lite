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