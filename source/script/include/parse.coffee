# parseShortDate
$.parseShortDate = (param) ->
  date = if $.type(param) == 'date' then param else new Date param
  arr = [
    date.getFullYear()
    1 + date.getMonth()
    date.getDate()
  ]
  for a, i in arr
    arr[i] = $.parseString a
    if i and arr[i].length < 2
      arr[i] = '0' + arr[i]
  arr.join ''

# parseString
$.parseString = (data) ->
  switch $.type d = data
    when 'string' then d
    when 'array'
      (JSON.stringify _obj: d)
      .replace /\{(.*)\}/, '$1'
      .replace /"_obj":/, ''
    when 'object'then JSON.stringify d
    else String d

# parsePts
$.parsePts = (number) ->
  if (n = (number or 0) | 0) >= 1e5 then (((n * 0.001) | 0) / 10) + '万'
  else n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

# parseJson
$.parseJson = $.parseJSON = (data) ->
  if $.type(data) != 'string'
    return data

  try
    res = eval "(#{data})"
    switch $.type res
      when 'object', 'array' then res
      else data
  catch err then data

# parseSafe
$.parseSafe = _.escape

# parseTemp
$.parseTemp = (string, object) ->
  s = string
  for k, v of object
    s = s.replace (new RegExp '\\[' + k + '\\]', 'g'), v
  # return
  s