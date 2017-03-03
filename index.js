(function() {
  var $, Callbacks, Deferred, _, parseType, request,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = require('lodash');

  request = require('request');

  module.exports = $ = {
    _: _,
    request: request,
    version: '0.5.0'
  };

  $.extend = _.extend;

  $.param = (require('querystring')).stringify;

  $.trim = _.trim;

  $.now = _.now;

  $.each = _.each;

  $.noop = _.noop;

  $.type = function(arg) {
    var type;
    type = Object.prototype.toString.call(arg).replace(/^\[object\s(.+)]$/, '$1').toLowerCase();
    if (type === 'uint8array') {
      return 'buffer';
    }
    return type;
  };

  $.serialize = function(string) {
    var a, b, i, key, len, ref, ref1, res, value;
    switch ($.type(string)) {
      case 'object':
        return string;
      case 'string':
        if (!~string.search(/=/)) {
          return {};
        }
        res = {};
        ref = _.trim(string.replace(/\?/g, '')).split('&');
        for (i = 0, len = ref.length; i < len; i++) {
          a = ref[i];
          b = a.split('=');
          ref1 = [_.trim(b[0]), _.trim(b[1])], key = ref1[0], value = ref1[1];
          if (key.length) {
            res[key] = value;
          }
        }
        return res;
      default:
        return {};
    }
  };

  Callbacks = (function() {
    function Callbacks(option) {
      this.option = $.extend({
        once: false,
        memory: false,
        unique: false,
        stopOnFalse: false
      }, option);
      this.status = {
        isDisabled: false,
        isLocked: false,
        isFired: false
      };
      this.list = [];
    }

    Callbacks.prototype.add = function() {
      var _push, args, fn, i, len;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (this.locked()) {
        return this;
      }
      _push = (function(_this) {
        return function(fn) {
          _this.list.push(fn);
          if (_this.option.memory && _this.fired()) {
            return fn.apply(null, _this.args);
          }
        };
      })(this);
      for (i = 0, len = args.length; i < len; i++) {
        fn = args[i];
        if (!($.type(fn) === 'function')) {
          continue;
        }
        if (this.option.unique) {
          if (!this.has(fn)) {
            _push(fn);
          }
          continue;
        }
        _push(fn);
      }
      return this;
    };

    Callbacks.prototype.disable = function() {
      this.status.isDisabled = true;
      return this;
    };

    Callbacks.prototype.disabled = function() {
      return !!this.status.isDisabled;
    };

    Callbacks.prototype.empty = function() {
      if (this.locked()) {
        return this;
      }
      this.list = [];
      return this;
    };

    Callbacks.prototype.fire = function() {
      var args, fn, i, len, ref, res;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (this.disabled()) {
        return this;
      }
      if (this.option.once && this.fired()) {
        return this;
      }
      ref = this.list;
      for (i = 0, len = ref.length; i < len; i++) {
        fn = ref[i];
        res = fn.apply(null, args);
        if (this.option.stopOnFalse && res === false) {
          break;
        }
      }
      this.status.isFired = true;
      if (this.option.memory) {
        this.args = args;
      }
      return this;
    };

    Callbacks.prototype.fired = function() {
      return !!this.status.isFired;
    };

    Callbacks.prototype.fireWith = function() {
      var args, context, fn, i, len, ref, res;
      context = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (this.disabled()) {
        return this;
      }
      if (this.option.once && this.fired()) {
        return this;
      }
      ref = this.list;
      for (i = 0, len = ref.length; i < len; i++) {
        fn = ref[i];
        res = fn.apply(context, args);
        if (this.option.stopOnFalse && res === false) {
          break;
        }
      }
      this.status.isFired = true;
      return this;
    };

    Callbacks.prototype.has = function(fn) {
      return indexOf.call(this.list, fn) >= 0;
    };

    Callbacks.prototype.lock = function() {
      this.status.isLocked = true;
      return this;
    };

    Callbacks.prototype.locked = function() {
      return !!this.status.isLocked;
    };

    Callbacks.prototype.remove = function(fn) {
      if (this.locked()) {
        return this;
      }
      _.remove(this.list, function(_fn) {
        return _fn === fn;
      });
      return this;
    };

    return Callbacks;

  })();

  $.Callbacks = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(Callbacks, args, function(){});
  };

  Deferred = require('Deferred');

  $.Deferred = Deferred;

  $.when = Deferred.when;

  parseType = function(res) {
    var type;
    type = res.headers['content-type'];
    if (type && ~type.search(/application\/json/)) {
      return 'json';
    }
    return 'text';
  };

  $.get = function(url, query) {
    var _query, _url, def;
    def = $.Deferred();
    if (query) {
      _url = url.replace(/\?.*/, '');
      _query = $.serialize(url.replace(/.*\?/, ''));
      _.extend(_query, query);
      url = _url + "?" + ($.param(_query));
    }
    $.request({
      method: 'GET',
      url: url,
      gzip: true
    }, function(err, res, body) {
      var type;
      if (err) {
        def.reject(err);
        return;
      }
      type = parseType(res);
      return def.resolve(type === 'json' ? JSON.parse(body) : body);
    });
    return def.promise();
  };

  $.post = function(url, query) {
    var def;
    def = $.Deferred();
    $.request({
      method: 'POST',
      url: url,
      form: query,
      gzip: true
    }, function(err, res, body) {
      var type;
      if (err) {
        def.reject(err);
        return;
      }
      type = parseType(res);
      return def.resolve(type === 'json' ? JSON.parse(body) : body);
    });
    return def.promise();
  };

}).call(this);
