_ = require 'lodash'

module.exports = $ =
  version: '0.2.9'
  startTime: _.now()
$.env = (process.env.NODE_ENV or 'production').toLowerCase()
$.debug = if $.env == 'development' then true else false