#require
domain = require 'domain'

#uncaughtException
process.on 'uncaughtException', (err) ->
  $.info 'fatal', err
  $.log err.stack

#try
$.try = (param...) ->
  p = param

  res =
    _domain: domain.create()

  res.try = (fn) ->
    $.next -> res._domain.run fn
    res

  res.catch = (fn) ->
    res._catch = fn
    res

  res._domain.on 'error', (err) ->
    $.info 'error', err
    res._catch? err

  #check param
  if ($.type p[0]) == 'function'
    res.try p[0]
  if ($.type p[1]) == 'function'
    res.catch p[1]

  res