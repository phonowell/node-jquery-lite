#get
$.get = (param...) ->
  #param
  p = param

  #require
  #http
  http = require if ~p[0].search 'https://' then 'https' else 'http'
  #cache
  cache = $.cache

  #url
  url = p[0] + if p[1] then '?' + $.param p[1] else ''

  #function
  f = ->
    #get
    req = http.get url, (res) ->
      data = []
      len = 0
      res
      .on 'data', (chunk) ->
        data.push chunk
        len += chunk.length
      .on 'end', ->
        data = Buffer.concat(data, len).toString()
        def.resolve data, (time = 900) -> if cache and time then cache.set url, data, time
    req.on 'error', (err) ->
      def.reject err

  #check cache
  if cache
    cache.get url, (cd) ->
      if cd
        #return
        def.resolve cd, ->
      else f()
  else f()

  #return
  def = new $.Deferred()

#post
$.post = (param...) ->
  #param
  p = param

  #http
  http = require if ~p[0].search 'https://' then 'https' else 'http'

  #check href
  href = do ->
    arr = p[0].toString().split '//'
    #http or https
    a = arr[0]
    #host
    i = arr[1].indexOf '/'
    i = arr[1].length if i < 0
    b = arr[1][0...i]
    #href
    c = arr[1][i...] or '/'
    #port
    b = b.split ':'
    d = b[1] or 80
    b = b[0]
    #http, host, href, port
    [a, b, c, d]
  #buffer
  buffer = $.param p[1]
  #post
  req = http.request
    host: href[1]
    port: href[3]
    method: 'POST'
    path: href[2]
    headers: 'Content-Type': 'application/x-www-form-urlencoded'
  , (res) ->
    data = ''
    res
    .on 'data', (chunk) ->
      data.push chunk
      len += chunk.length
    .on 'end', ->
      data = Buffer.concat(data, len).toString()
      def.resolve data
  req.write buffer
  req.end()
  req.on 'error', (err) ->
    def.reject err
  #return
  def = new $.Deferred()

#getCache
#$.getCache = (url, p...) ->
#  #param
#  [time, callback] = if p[1] then [p[0], p[1]] else [900, p[0]]
#  #check cache
#  if !cache
#    $.get url
#    .done callback
#    .fail