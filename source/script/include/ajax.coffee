http = require 'http'
https = require 'https'

#get
$.get = (param...) ->
  p = param

  _http = if ~p[0].search 'https://' then https else http

  url = p[0] + if p[1] then '?' + $.param p[1] else ''

  req = _http.get url, (res) ->
    data = []
    len = 0
    res
    .on 'data', (chunk) ->
      data.push chunk
      len += chunk.length
    .on 'end', ->
      data = Buffer.concat(data, len).toString()
      def.resolve data
  req.on 'error', (err) ->
    def.reject err

  def = $.Deferred()

#post
$.post = (param...) ->
  p = param

  _http = if ~p[0].search 'https://' then https else http

  #function
  href = do ->

    arr = p[0].split '//'

    #type
    _type = if ~arr[0].search 'https' then 'https' or 'http'

    #host
    i = arr[1].indexOf '/'
    if i < 0 then i = arr[1].length
    _host = arr[1][0...i]

    #href
    _href = arr[1][i...] or '/'

    #port
    _host = _host.split ':'
    _port = _host[1] or 80
    _host = _host[0]

    #return
    [_type, _host, _href, _port]

  buffer = $.param p[1]

  req = _http.request
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

  def = $.Deferred()