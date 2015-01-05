#$
global.$ = {}

#require
for a in ['error', 'basic', 'parse', 'ajax', 'promise', 'etc']
  require './lib/' + a

#init

#version
$.version = '0.1.0'

#start time
$.st = $.now()

#env
$.env = (process.env.NODE_ENV or 'production').toLowerCase()

#debug
$.debug = if $.env == 'development' then true else false