# node-jquery-lite

A tiny toy in order to write lines in jQuery style a little easier for Node.js.

## Install

```
$ npm i node-jquery-lite
```

## Usage

```
$ = require 'node-jquery-lite'

a = $.get '/api/path/a'
b = $.get '/api/path/b'

$.when a, b
.fail (msg) -> console.log msg
.done (data) ->
  if $.type(data) != 'array' then return
  ...  
```

## Methods

- `$.Callbacks()`
- `$.Deferred()`
- `$.each()`
- `$.extend()`
- `$.get()`
- `$.noop()`
- `$.now()`
- `$.param()`
- `$.post()`
- `$.serialize()`
- `$.trim()`
- `$.type()`
- `$.when()`

Methods below come from required libraries.

- `$._()`
- `$.request()`
    
## Attention

This project is **NOT STABLE**.

## Test

```
$ npm test
```

## Updates

Look [HERE](update.md).

## Todo

Look [HERE](todo.md).

## License

Look [HERE](license.md).