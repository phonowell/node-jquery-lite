$.extend = _.extend # extend
$.param = (require 'querystring').stringify # param
$.trim = _.trim # trim
$.now = _.now # now
$.each = _.each # each
$.noop = _.noop # noop

# type
$.type = (param) ->
  type = Object::toString.call(param).replace(/^\[object\s(.+)\]$/, '$1').toLowerCase()
  if type == 'uint8array' then return 'buffer'
  type

# serialize
$.serialize = (string) ->
  switch $.type string
    when 'object' then string
    when 'string'
      if !~string.search /=/ then return {}
      res = {}
      for a in _.trim(string.replace /\?/g, '').split '&'
        b = a.split '='
        [key, value] = [_.trim(b[0]), _.trim b[1]]
        if key.length then res[key] = value
      res
    else {}