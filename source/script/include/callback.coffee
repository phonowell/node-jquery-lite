# $.Callbacks().add()
# $.Callbacks().disable()
# $.Callbacks().disabled()
# $.Callbacks().empty()
# $.Callbacks().fire()
# $.Callbacks().fired()
# $.Callbacks().fireWith()
# $.Callbacks().has()
# $.Callbacks().lock()
# $.Callbacks().locked()
# $.Callbacks().remove()
# $.Callbacks()

# Callbacks()
class Callbacks

  constructor: (option) ->

    @option = $.extend
      once: false
      memory: false
      unique: false
      stopOnFalse: false
    , option

    @status =
      isDisabled: false
      isLocked: false
      isFired: false
    @list = []

  # Callbacks().add()
  add: (args...) ->
    if @locked() then return @

    _push = (fn) =>
      @list.push fn
      if @option.memory and @fired()
        fn @args...

    for fn in args when $.type(fn) == 'function'
      if @option.unique
        if !@has(fn) then _push fn
        continue
      _push fn

    @

  # Callbacks().disable()
  disable: ->
    @status.isDisabled = true
    @

  # Callbacks().disabled()
  disabled: -> !!@status.isDisabled

  # Callbacks().empty()
  empty: ->
    if @locked() then return @
    @list = []
    @

  # Callbacks().fire()
  fire: (args...) ->
    if @disabled() then return @
    if @option.once and @fired() then return @

    for fn in @list
      res = fn args...
      if @option.stopOnFalse and res == false then break
    @status.isFired = true

    if @option.memory then @args = args

    @

  # Callbacks().fired()
  fired: -> !!@status.isFired

  # Callbacks().fireWith()
  fireWith: (context, args...) ->
    if @disabled() then return @
    if @option.once and @fired() then return @

    for fn in @list
      res = fn.apply context, args
      if @option.stopOnFalse and res == false then break
    @status.isFired = true

    @

  # Callbacks().has()
  has: (fn) -> fn in @list

  # Callbacks().lock()
  lock: ->
    @status.isLocked = true
    @

  # Callbacks().locked()
  locked: -> !!@status.isLocked

  # Callbacks().remove()
  remove: (fn) ->
    if @locked() then return @
    _.remove @list, (_fn) -> _fn == fn
    @

# $.Callbacks()
$.Callbacks = (args...) -> new Callbacks args...