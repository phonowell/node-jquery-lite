#parseTime
$.parseTime = (param) -> $.parseTime.trans $.timeStamp param
$.parseTime.trans = (t) ->
  dt = new Date t
  ts = dt.getTime()

  dtNow = new Date()
  tsNow = dtNow.getTime()

  tsDistance = tsNow - ts

  hrMin = dt.getHours() + '时' + ((if dt.getMinutes() < 10 then '0' else '')) + dt.getMinutes() + '分'
  longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin
  longLongAgo = dt.getFullYear() + '年' + longAgo

  #future
  if tsDistance < 0
    return '刚刚'

  #years ago
  if (tsDistance / 1000 / 60 / 60 / 24 / 365) | 0
    return longLongAgo

  #three days ago
  if (dayAgo = tsDistance / 1000 / 60 / 60 / 24) > 3
    #if not same year
    if dt.getFullYear() != dtNow.getFullYear()
      return longLongAgo
    return longAgo

  if (dayAgo = (dtNow.getDay() - dt.getDay() + 7) % 7) > 2
    return longAgo

  #one day ago
  if dayAgo > 1
    return '前天 ' + hrMin

  #12 hours ago
  if (hrAgo = tsDistance / 1000 / 60 / 60) > 12
    return (if dt.getDay() != dtNow.getDay() then '昨天 ' else '今天 ') + hrMin

  #hours ago
  if hrAgo = (tsDistance / 1000 / 60 / 60 % 60) | 0
    return hrAgo + '小时前'

  #minutes ago
  if minAgo = (tsDistance / 1000 / 60 % 60) | 0
    return minAgo + '分钟前'

  #30 seconds ago
  if (secAgo = (tsDistance / 1000 % 60) | 0) > 30
    return secAgo + '秒前'

  #just now
  '刚刚'

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