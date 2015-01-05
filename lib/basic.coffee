#extend
$.extend = (target, object) ->
  t = target
  for k, v of object
    t[k] = v
  t

#type
$.type = (param) ->
  switch t = typeof p = param
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

#param
$.param = (require 'querystring').stringify

#trim
$.trim = (str) -> str.toString().replace /(^\s*)|(\s*$)/g, ''

#now
$.now = Date.now

#callbacks
$.Callbacks = (flags) ->
  r =
    #status
    status:
      fired: false
    #list
    list: []
    #add
    add: (p...) ->
      #push
      for fn in p
        r.list.push fn
      #return
      r
    #remove
    remove: (fn) ->
      for f, i in r.list when f == fn
        r.list.splice i, 1
        break
      #return
      r
    #has
    has: (fn) ->
      if fn in r.list then true else false
    #empty
    empty: ->
      r.list = []
      #return
      r
    #fire
    fire: (p...) ->
      for f in r.list
        f? p...
      #set status
      r.status.fired = true
      #return
      r
    #fired
    fired: -> r.status.fired