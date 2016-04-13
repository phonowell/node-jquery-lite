$.extend = _.extend #extend
$.param = (require 'querystring').stringify #param
$.trim = _.trim #trim
$.now = _.now #now
$.each = _.each #each
$.noop = _.noop #noop

#type
$.type = (param) ->
  type = Object::toString.call(param).replace(/^\[object\s(.+)\]$/, '$1').toLowerCase()
  if type == 'uint8array'
    return 'buffer'
  type