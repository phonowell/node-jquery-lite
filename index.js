(function() {
  var $, VERSION, _;

  _ = require('lodash');

  VERSION = '0.7.0';

  $ = {
    _: _,
    VERSION: VERSION
  };

  module.exports = $;


  /*
  
    $.each()
    $.extend()
    $.noop()
    $.now()
    $.param()
    $.parseJSON(data)
    $.trim()
    $.type(arg)
   */

  $.each = _.each;

  $.extend = _.extend;

  $.noop = _.noop;

  $.now = _.now;

  $.param = (require('querystring')).stringify;

  $.parseJSON = function(data) {
    var _parse;
    _parse = function(string) {
      var err, ref, res;
      try {
        res = eval("(" + string + ")");
        if ((ref = $.type(res)) === 'object' || ref === 'array') {
          return res;
        }
        return data;
      } catch (error) {
        err = error;
        return data;
      }
    };
    switch ($.type(data)) {
      case 'array':
        return data;
      case 'buffer':
        return _parse(data.toString());
      case 'object':
        return data;
      case 'string':
        return _parse(data);
      default:
        throw new Error('invalid argument type');
    }
  };

  $.trim = _.trim;

  $.type = function(arg) {
    var type;
    type = Object.prototype.toString.call(arg).replace(/^\[object\s(.+)]$/, '$1').toLowerCase();
    if (type === 'uint8array') {
      return 'buffer';
    }
    return type;
  };

}).call(this);
