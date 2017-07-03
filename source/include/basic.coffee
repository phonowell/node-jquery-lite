###

  $.each()
  $.extend()
  $.noop()
  $.now()
  $.param()
  $.parseJSON(data)


  $.trim()
  $.type(arg)

###

$.each = _.each

$.extend = _.extend

$.noop = _.noop

$.now = _.now

$.param = (require 'querystring').stringify

$.parseJSON = (data) ->
  if $.type(data) != 'string' then return data

  try
    res = eval "(#{data})"
    if $.type(res) in ['object', 'array'] then return res
    data
  catch err then data

$.trim = _.trim

$.type = (arg) ->

  type = Object::toString.call arg
  .replace /^\[object\s(.+)]$/, '$1'
  .toLowerCase()

  if type == 'uint8array' then return 'buffer'

  type