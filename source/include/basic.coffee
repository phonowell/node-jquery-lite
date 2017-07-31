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

  _parse = (string) ->
    try
      res = eval "(#{string})"
      if $.type(res) in ['object', 'array'] then return res
      data
    catch err then data

  switch $.type data
    when 'array' then data
    when 'buffer' then _parse data.toString()
    when 'object' then data
    when 'string' then _parse data
    else throw new Error 'invalid argument type'

$.trim = _.trim

$.type = (arg) ->

  type = Object::toString.call arg
  .replace /^\[object\s(.+)]$/, '$1'
  .toLowerCase()

  if type == 'uint8array' then return 'buffer'

  type