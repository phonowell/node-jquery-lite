(function() {
  var $, _;

  $ = {};

  _ = require('lodash');

  $._ = _;

  // return
  module.exports = $;

  /*
  each()
  extend()
  noop()
  now()
  param()
  parseJSON(data)
  trim()
  type(arg)
  */
  $.each = _.each;

  $.extend = _.extend;

  $.noop = _.noop;

  $.now = _.now;

  $.param = (require('querystring')).stringify;

  $.parseJSON = JSON.parse;

  $.trim = _.trim;

  $.type = function(arg) {
    var type;
    type = Object.prototype.toString.call(arg).replace(/^\[object\s(.+)]$/, '$1').toLowerCase();
    if (type === 'asyncfunction') {
      return 'async function';
    }
    if (type === 'uint8array') {
      return 'buffer';
    }
    return type; // return
  };

}).call(this);
