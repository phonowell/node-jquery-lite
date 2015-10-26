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
  p = param
  t = typeof p
  switch t
    when 'object'
      if p
        #check if buffer
        if p.fill
          return 'buffer'
        #check if array
        if toString.call(p) == '[object Array]'
          return 'array'
        #object
        'object'
      else
        #check if null
        if p == null
          return 'null'
        #undefined
        'undefined'
    when 'number'
      #check if NaN
      if p != +p
        return 'NaN'
      #number
      t
    else t