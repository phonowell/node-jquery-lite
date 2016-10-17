# $.Deferred().always()
# $.Deferred().done()
# $.Deferred().fail()
# $.Deferred().notify()
# $.Deferred().notifyWith()
# $.Deferred().progress()
# $.Deferred().promise()
# $.Deferred().reject()
# $.Deferred().rejectWith()
# $.Deferred().resolve()
# $.Deferred().resolveWith()
# $.Deferred().state()
# $.Deferred().then()
# $.Deferred()
# $.when()
# .promise()

# Deferred()
class Deferred

  constructor: ->
    @status =
      isRejected: false
      isResolved: false
      state: 'pending'
    @list =
      resolve: $.Callbacks once: true
      reject: $.Callbacks once: true
      notify: $.Callbacks()

  # _add
  _add = (fn, list) ->
    if $.type(fn) == 'function' then list.add fn

  # Deferred().always()
  always: (cb) ->
    @done cb
    @fail cb

  # Deferred().done()
  done: (cb) ->
    _add cb, @list.resolve
    @

  # Deferred().fail()
  fail: (cb) ->
    _add cb, @list.reject
    @

  # Deferred().notify()
  notify: (args...) ->
    @args = args
    @list.notify.fire args...
    @

  # Deferred().notifyWith()
  notifyWith: (args...) ->
    @args = args
    @list.notify.fireWith args...
    @

  # Deferred().progress()
  progress: (cb) ->
    _add cb, @list.notify
    @

  # Deferred().promise()
  promise: -> @

  # Deferred().reject()
  reject: (args...) ->
    @status.state = 'rejected'
    @args = args
    @list.reject.fire args...
    @

  # Deferred().rejectWith()
  rejectWith: (args...) ->
    @status.state = 'rejected'
    @args = args
    @list.reject.fireWith args...
    @

  # Deferred().resolve()
  resolve: (args...) ->
    @status.state = 'resolved'
    @args = args
    @list.resolve.fire args...
    @

  # Deferred().resolveWith()
  resolveWith: (args...) ->
    @status.state = 'resolved'
    @args = args
    @list.resolve.fireWith args...
    @

  # Deferred().state()
  state: -> @status.state

  # Deferred().then()
  then: (args...) ->
    @done args[0]
    @fail args[1]

# $.Deferred()
$.Deferred = -> new Deferred()

# $.when()
$.when = (args...) ->

  def = $.Deferred()

  parse = (arr) -> if arr.length == 1 then arr[0] else arr

  list =
    state: []
    def: []

  for _d, _i in args
    do (d = _d, i = _i) ->

      # if it is not a deferred object
      if !d?.status?.state
        list.state[i] = 'resolved'
        list.def[i] = d
        return

      state = d.status.state

      # already resolved
      if state == 'resolved'
        list.state[i] = 'resolved'
        list.def[i] = parse d.args
        return

      # already rejected
      if state == 'rejected'
        list.state = null
        list.def = d.args
        return

      # still pending
      list.state[i] = 'pending'
      d.done (_args...) -> def.notify i, 'resolved', _args
      .fail (_args...) -> def.reject _args...

    if !list.state then break

  # status rejected
  if !list.state
    $.next -> def.reject.apply def, list.def
    return def.promise()

  # no pending, as all resolved
  if !('pending' in list.state)
    $.next -> def.resolve.apply def, list.def
    return def.promise()

  # waiting for notify
  def.progress (i, state, _arg) ->
    list.state[i] = state
    list.def[i] = parse _arg

    if 'pending' in list.state then return

    def.resolve.apply def, list.def

  def.promise()

#.promise()