#require
domain = require 'domain'

#next
$.next = process.nextTick

#uncaughtException
process.on 'uncaughtException', (err) ->
  $.info 'fatal', err
  $.log err.stack

#try
$.try = (p...) ->
  #o
  o =
    #domain
    _domain: domain.create()

    #try
    try: (fn) ->
      $.next ->
        o._domain.run fn
      #return
      o

    #catch
    catch: (fn) ->
      o._catch = fn
      #return
      o

  #bind action
  o._domain.on 'error', (err) ->
    $.info 'error', err
    o._catch? err

  #check param
  if ($.type p[0]) == 'function'
    o.try p[0]
  if ($.type p[1]) == 'function'
    o.catch p[1]

  #return
  o