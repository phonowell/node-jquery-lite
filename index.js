(function() {
  var $, Callbacks, Deferred, _, parseType, request,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = require('lodash');

  request = require('request');

  module.exports = $ = {
    _: _,
    request: request,
    version: '0.4.1'
  };

  $.extend = _.extend;

  $.param = (require('querystring')).stringify;

  $.trim = _.trim;

  $.now = _.now;

  $.each = _.each;

  $.noop = _.noop;

  $.type = function(arg) {
    var type;
    type = Object.prototype.toString.call(arg).replace(/^\[object\s(.+)\]$/, '$1').toLowerCase();
    if (type === 'uint8array') {
      return 'buffer';
    }
    return type;
  };

  $.serialize = function(string) {
    var a, b, j, key, len, ref, ref1, res, value;
    switch ($.type(string)) {
      case 'object':
        return string;
      case 'string':
        if (!~string.search(/=/)) {
          return {};
        }
        res = {};
        ref = _.trim(string.replace(/\?/g, '')).split('&');
        for (j = 0, len = ref.length; j < len; j++) {
          a = ref[j];
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
      var _push, args, fn, j, len;
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
      for (j = 0, len = args.length; j < len; j++) {
        fn = args[j];
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
      var args, fn, j, len, ref, res;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (this.disabled()) {
        return this;
      }
      if (this.option.once && this.fired()) {
        return this;
      }
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        fn = ref[j];
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
      var args, context, fn, j, len, ref, res;
      context = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (this.disabled()) {
        return this;
      }
      if (this.option.once && this.fired()) {
        return this;
      }
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        fn = ref[j];
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

  Deferred = (function() {
    var _add;

    function Deferred() {
      this.status = {
        isRejected: false,
        isResolved: false,
        state: 'pending'
      };
      this.list = {
        resolve: $.Callbacks({
          once: true
        }),
        reject: $.Callbacks({
          once: true
        }),
        notify: $.Callbacks()
      };
    }

    _add = function(fn, list) {
      if ($.type(fn) === 'function') {
        return list.add(fn);
      }
    };

    Deferred.prototype.always = function(cb) {
      this.done(cb);
      return this.fail(cb);
    };

    Deferred.prototype.done = function(cb) {
      _add(cb, this.list.resolve);
      return this;
    };

    Deferred.prototype.fail = function(cb) {
      _add(cb, this.list.reject);
      return this;
    };

    Deferred.prototype.notify = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.args = args;
      (ref = this.list.notify).fire.apply(ref, args);
      return this;
    };

    Deferred.prototype.notifyWith = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.args = args;
      (ref = this.list.notify).fireWith.apply(ref, args);
      return this;
    };

    Deferred.prototype.progress = function(cb) {
      _add(cb, this.list.notify);
      return this;
    };

    Deferred.prototype.promise = function() {
      return this;
    };

    Deferred.prototype.reject = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.status.state = 'rejected';
      this.args = args;
      (ref = this.list.reject).fire.apply(ref, args);
      return this;
    };

    Deferred.prototype.rejectWith = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.status.state = 'rejected';
      this.args = args;
      (ref = this.list.reject).fireWith.apply(ref, args);
      return this;
    };

    Deferred.prototype.resolve = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.status.state = 'resolved';
      this.args = args;
      (ref = this.list.resolve).fire.apply(ref, args);
      return this;
    };

    Deferred.prototype.resolveWith = function() {
      var args, ref;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.status.state = 'resolved';
      this.args = args;
      (ref = this.list.resolve).fireWith.apply(ref, args);
      return this;
    };

    Deferred.prototype.state = function() {
      return this.status.state;
    };

    Deferred.prototype.then = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      this.done(args[0]);
      return this.fail(args[1]);
    };

    return Deferred;

  })();

  $.Deferred = function() {
    return new Deferred();
  };

  $.when = function() {
    var _d, _i, args, def, fn1, j, len, list, parse;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    def = $.Deferred();
    parse = function(arr) {
      if (arr.length === 1) {
        return arr[0];
      } else {
        return arr;
      }
    };
    list = {
      state: [],
      def: []
    };
    fn1 = function(d, i) {
      var ref, state;
      if (!(d != null ? (ref = d.status) != null ? ref.state : void 0 : void 0)) {
        list.state[i] = 'resolved';
        list.def[i] = d;
        return;
      }
      state = d.status.state;
      if (state === 'resolved') {
        list.state[i] = 'resolved';
        list.def[i] = parse(d.args);
        return;
      }
      if (state === 'rejected') {
        list.state = null;
        list.def = d.args;
        return;
      }
      list.state[i] = 'pending';
      return d.done(function() {
        var _args;
        _args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return def.notify(i, 'resolved', _args);
      }).fail(function() {
        var _args;
        _args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return def.reject.apply(def, _args);
      });
    };
    for (_i = j = 0, len = args.length; j < len; _i = ++j) {
      _d = args[_i];
      fn1(_d, _i);
      if (!list.state) {
        break;
      }
    }
    if (!list.state) {
      $.next(function() {
        return def.reject.apply(def, list.def);
      });
      return def.promise();
    }
    if (!(indexOf.call(list.state, 'pending') >= 0)) {
      $.next(function() {
        return def.resolve.apply(def, list.def);
      });
      return def.promise();
    }
    def.progress(function(i, state, _arg) {
      list.state[i] = state;
      list.def[i] = parse(_arg);
      if (indexOf.call(list.state, 'pending') >= 0) {
        return;
      }
      return def.resolve.apply(def, list.def);
    });
    return def.promise();
  };

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
