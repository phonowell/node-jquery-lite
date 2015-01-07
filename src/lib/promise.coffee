#deferred
class $.Deferred
  #done
  @::done = (callback) ->
    @list or=
      done: $.Callbacks()
      fail: $.Callbacks()
    @list.done.add callback
    @
  #fail
  @::fail = (callback) ->
    @list or=
      done: $.Callbacks()
      fail: $.Callbacks()
    @list.fail.add callback
    @
  #resolve
  @::resolve = (p...) ->
    if @list
      @list.done.fire p...
    @
  #reject
  @::reject = (p...) ->
    if @list
      @list.fail.fire p...
    @