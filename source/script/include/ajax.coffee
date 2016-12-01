request = require 'request'

parseType = (res) ->
  type = res.headers['content-type']

  if type and ~type.search /application\/json/
    return 'json'

  'text'

#get
$.get = (url, query) ->

  def = $.Deferred()

  if query
    _url = url.replace /\?.*/, ''
    _query = $.serialize url.replace /.*\?/, ''
    _.extend _query, query
    url = "#{_url}?#{$.param _query}"

  request
    method: 'GET'
    url: url
    gzip: true
  , (err, res, body) ->
    if err
      def.reject err
      return

    type = parseType res

    def.resolve if type == 'json' then JSON.parse body else body

  def.promise()

#post
$.post = (url, query) ->

  def = $.Deferred()

  request
    method: 'POST'
    url: url
    form: query
    gzip: true
  , (err, res, body) ->
    if err
      def.reject err
      return

    type = parseType res

    def.resolve if type == 'json' then JSON.parse body else body

  def.promise()