#extend
$.extend = _.extend

#param
$.param = (require 'querystring').stringify

#trim
$.trim = _.trim

#now
$.now = _.now

#type
$.type = (param) ->
  type = Object::toString.call(param).replace(/^\[object\s(.+)\]$/, '$1').toLowerCase()
  if type == 'uint8array'
    return 'buffer'
  type

#noop
$.noop = _.noop