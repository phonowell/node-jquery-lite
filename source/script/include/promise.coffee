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