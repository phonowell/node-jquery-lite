#parseTime
$.parseTime = (param, future) ->
  $.parseTime.trans $.timeStamp(param), future

#trans
$.parseTime.trans = (t, future) ->

  dt = new Date t
  ts = dt.getTime()

  dtNow = new Date()
  tsNow = dtNow.getTime()

  tsDistance = tsNow - ts

  hrMin = dt.getHours() + '时' + ((if dt.getMinutes() < 10 then '0' else '')) + dt.getMinutes() + '分'
  longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin
  longLongAgo = dt.getFullYear() + '年' + longAgo

  #future
  i = 0
  if tsDistance < 0
    if !future then return '刚刚'
    i = 1
  if i then tsDistance = -tsDistance + 500

  #years ago
  if (tsDistance / 31536e6) | 0
    return longLongAgo

  #three days ago
  if (dayAgo = tsDistance / 864e5) > 3
    #if not same year
    if dt.getFullYear() != dtNow.getFullYear()
      return longLongAgo
    return longAgo

  #  if (dayAgo = (dtNow.getDay() - dt.getDay() + 7) % 7) > 2
  #    return longAgo

  #one day ago
  if dayAgo > 1
    return ['前天 ', '后天 '][i] + hrMin

  #12 hours ago
  if (hrAgo = tsDistance / 36e5) > 12
    return (if dt.getDay() != dtNow.getDay() then ['昨天 ', '明天 '][i] else '今天 ') + hrMin

  #hours ago
  if hrAgo = (tsDistance / 36e5 % 60) | 0
    return hrAgo + ['小时前', '小时后'][i]

  #minutes ago
  if minAgo = (tsDistance / 6e4 % 60) | 0
    return minAgo + ['分钟前', '分钟后'][i]

  #30 seconds ago
  if (secAgo = (tsDistance / 1e3 % 60) | 0) > 30
    return secAgo + ['秒前', '秒后'][i]

  #just now
  '刚刚'

#parseShortDate
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

#parseString
$.parseString = (data) ->
  switch $.type d = data
    when 'string' then d
    when 'number' then d.toString()
    when 'array'
      (JSON.stringify _obj: d)
      .replace /\{(.*)\}/, '$1'
      .replace /"_obj":/, ''
    when 'object'then JSON.stringify d
    when 'boolean' then d.toString()
    when 'undefined' then 'undefined'
    when 'null' then 'null'
    else
      try
        d.toString()
      catch e
        ''

#parsePts
$.parsePts = (number) ->
  if (n = (number or 0) | 0) >= 1e5 then (((n * 0.001) | 0) / 10) + '万'
  else n.toString().replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'

#parseJson
$.parseJson = $.parseJSON = (data) ->
  d = data

  fn = (p) ->
    try
      res = eval "(" + p + ")"

      switch $.type res
        when 'object', 'array'
          res
        else
          null
    catch e
      null

  switch $.type d
    when 'string' then fn d
    when 'object' then d
    else null

#parseSafe
$.parseSafe = _.escape

#parseTemp
$.parseTemp = (string, object) ->
  s = string
  for k, v of object
    s = s.replace (new RegExp '\\[' + k + '\\]', 'g'), v
  #return
  s