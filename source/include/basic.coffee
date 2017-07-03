$.extend = _.extend
$.param = (require 'querystring').stringify
$.trim = _.trim
$.now = _.now
$.each = _.each
$.noop = _.noop

$.type = (arg) ->

  type = Object::toString.call arg
  .replace /^\[object\s(.+)]$/, '$1'
  .toLowerCase()

  if type == 'uint8array' then return 'buffer'

  type