#parseTime
$.parseTime = (param) ->
  #trans
  trans = (t) ->
    dt = new Date t
    ts = dt.getTime()
    dtNow = new Date()
    tsNow = dtNow.getTime()
    tsDistance = tsNow - ts
    hrMin = dt.getHours() + '时' + ((if dt.getMinutes() < 10 then '0' else '')) + dt.getMinutes() + '分'
    longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin
    longLongAgo = dt.getFullYear() + '年' + longAgo
    if tsDistance < 0 then '刚刚' else
      if (tsDistance / 1000 / 60 / 60 / 24 / 365) | 0 > 0 then longLongAgo else
        if (dayAgo = tsDistance / 1000 / 60 / 60 / 24) > 3 then (if dt.getFullYear() != dtNow.getFullYear() then longLongAgo else longAgo) else
          if (dayAgo = (dtNow.getDay() - dt.getDay() + 7) % 7) > 2 then longAgo else
            if dayAgo > 1 then '前天 ' + hrMin else
              if (hrAgo = tsDistance / 1000 / 60 / 60) > 12 then (if dt.getDay() != dtNow.getDay() then '昨天 ' else '今天 ') + hrMin else
                if (hrAgo = (tsDistance / 1000 / 60 / 60 % 60) | 0) > 0 then hrAgo + '小时前' else
                  if (minAgo = (tsDistance / 1000 / 60 % 60) | 0) > 0 then minAgo + '分钟前' else
                    if (secAgo = (tsDistance / 1000 % 60) | 0) > 0 then secAgo + '秒前' else '刚刚'
  #trans
  trans $.timeStamp param

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
$.parseJson = (data) ->
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