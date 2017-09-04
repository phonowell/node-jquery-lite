$ = require './../index'
_ = $._

# function

$.parseString = (data) ->

  switch $.type data

    when 'array'

      (JSON.stringify __container__: data)
      .replace /{(.*)}/, '$1'
      .replace /"__container__":/, ''

    when 'object' then JSON.stringify data

    when 'string' then data

    else new String data

# test variable

SUBJECT = [
  1024 # number
  'hello world' # string
  true # boolean
  [1, 2, 3] # array
  {a: 1, b: 2} # object
  -> return null # function
  new Date() # date
  new Error('All Right') # error
  new Buffer('String') # buffer
  null # null
  undefined # undefined
  NaN # NaN
]

# test function

checkIsLodash = (name) ->

  describe "$.#{name}()", ->

    it "$.#{name}()", ->

      if $[name] != _[name]
        throw new Error()

# test lines

# each()
checkIsLodash 'each'

# extend
checkIsLodash 'extend'

# noop
checkIsLodash 'noop'

# now
checkIsLodash 'now'

describe '$.param()', ->

  it '$.param()', ->

    if $.param != (require 'querystring').stringify
      throw new Error()

describe '$.parseJSON()', ->

  it '$.parseJSON()', ->

    if $.parseJSON != JSON.parse
      throw new Error()

# trim
checkIsLodash 'trim'

describe '$.type()', ->
  LIST = [
    'number'
    'string'
    'boolean'
    'array'
    'object'
    'function'
    'date'
    'error'
    'buffer'
    'null'
    'undefined'
    'number'
  ]
  _.each LIST, (a, i) ->
    it a, ->
      if $.type(SUBJECT[i]) != a
        throw new Error()
