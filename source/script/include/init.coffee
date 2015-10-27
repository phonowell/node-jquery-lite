_ = require 'lodash'

module.exports = $ =
  version: '0.3.0'
  startTime: _.now()
$.env = (process.env.NODE_ENV or 'production').toLowerCase()
$.debug = if $.env == 'development' then true else false