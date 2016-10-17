(function() {
  var $, Callbacks, Deferred, _, parseType, request,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = require('lodash');

  module.exports = $ = {
    _: _,
    version: '0.3.15'
  };

  $.extend = _.extend;

  $.param = (require('querystring')).stringify;

  $.trim = _.trim;

  $.now = _.now;

  $.each = _.each;

  $.noop = _.noop;

  $.type = function(param) {
    var type;
    type = Object.prototype.toString.call(param).replace(/^\[object\s(.+)\]$/, '$1').toLowerCase();
    if (type === 'uint8array') {
      return 'buffer';
    }
    return type;
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

  $.parseTime = function(param, future) {
    return $.parseTime.trans($.timeStamp(param), future);
  };

  $.parseTime.trans = function(t, future) {
    var dayAgo, dt, dtNow, hrAgo, hrMin, i, longAgo, longLongAgo, minAgo, secAgo, ts, tsDistance, tsNow;
    dt = new Date(t);
    ts = dt.getTime();
    dtNow = new Date();
    tsNow = dtNow.getTime();
    tsDistance = tsNow - ts;
    hrMin = dt.getHours() + '时' + (dt.getMinutes() < 10 ? '0' : '') + dt.getMinutes() + '分';
    longAgo = (dt.getMonth() + 1) + '月' + dt.getDate() + '日(星期' + ['日', '一', '二', '三', '四', '五', '六'][dt.getDay()] + ') ' + hrMin;
    longLongAgo = dt.getFullYear() + '年' + longAgo;
    i = 0;
    if (tsDistance < 0) {
      if (!future) {
        return '刚刚';
      }
      i = 1;
    }
    if (i) {
      tsDistance = -tsDistance + 500;
    }
    if ((tsDistance / 31536e6) | 0) {
      return longLongAgo;
    }
    if ((dayAgo = tsDistance / 864e5) > 3) {
      if (dt.getFullYear() !== dtNow.getFullYear()) {
        return longLongAgo;
      }
      return longAgo;
    }
    if (dayAgo > 1) {
      return ['前天 ', '后天 '][i] + hrMin;
    }
    if ((hrAgo = tsDistance / 36e5) > 12) {
      return (dt.getDay() !== dtNow.getDay() ? ['昨天 ', '明天 '][i] : '今天 ') + hrMin;
    }
    if (hrAgo = (tsDistance / 36e5 % 60) | 0) {
      return hrAgo + ['小时前', '小时后'][i];
    }
    if (minAgo = (tsDistance / 6e4 % 60) | 0) {
      return minAgo + ['分钟前', '分钟后'][i];
    }
    if ((secAgo = (tsDistance / 1e3 % 60) | 0) > 30) {
      return secAgo + ['秒前', '秒后'][i];
    }
    return '刚刚';
  };

  $.parseShortDate = function(param) {
    var a, arr, date, i, j, len;
    date = $.type(param) === 'date' ? param : new Date(param);
    arr = [date.getFullYear(), 1 + date.getMonth(), date.getDate()];
    for (i = j = 0, len = arr.length; j < len; i = ++j) {
      a = arr[i];
      arr[i] = $.parseString(a);
      if (i && arr[i].length < 2) {
        arr[i] = '0' + arr[i];
      }
    }
    return arr.join('');
  };

  $.parseString = function(data) {
    var d, err;
    switch ($.type(d = data)) {
      case 'string':
        return d;
      case 'number':
        return d.toString();
      case 'array':
        return (JSON.stringify({
          _obj: d
        })).replace(/\{(.*)\}/, '$1').replace(/"_obj":/, '');
      case 'object':
        return JSON.stringify(d);
      case 'boolean':
        return d.toString();
      case 'undefined':
        return 'undefined';
      case 'null':
        return 'null';
      default:
        try {
          return d.toString();
        } catch (error) {
          err = error;
          return '';
        }
    }
  };

  $.parsePts = function(number) {
    var n;
    if ((n = (number || 0) | 0) >= 1e5) {
      return (((n * 0.001) | 0) / 10) + '万';
    } else {
      return n.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
    }
  };

  $.parseJson = $.parseJSON = function(data) {
    var err, res;
    if ($.type(data) !== 'string') {
      return data;
    }
    try {
      res = eval("(" + data + ")");
      switch ($.type(res)) {
        case 'object':
        case 'array':
          return res;
        default:
          return data;
      }
    } catch (error) {
      err = error;
      return data;
    }
  };

  $.parseSafe = _.escape;

  $.parseTemp = function(string, object) {
    var k, s, v;
    s = string;
    for (k in object) {
      v = object[k];
      s = s.replace(new RegExp('\\[' + k + '\\]', 'g'), v);
    }
    return s;
  };

  request = require('request');

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
    request({
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
      return def.resolve(type === 'json' ? $.parseJson(body) : body);
    });
    return def.promise();
  };

  $.post = function(url, query) {
    var def;
    def = $.Deferred();
    request({
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
      return def.resolve(type === 'json' ? $.parseJson(body) : body);
    });
    return def.promise();
  };

  $.next = function() {
    var fn, param, ref, time;
    param = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    ref = !param[1] ? [0, param[0]] : param, time = ref[0], fn = ref[1];
    if (time) {
      setTimeout(fn, time);
      return;
    }
    return process.nextTick(fn);
  };

  $.log = console.log;

  $.info = function() {
    var a, arr, d, msg, param, ref, t, type;
    param = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    ref = !param[1] ? ['default', param[0]] : param, type = ref[0], msg = ref[1];
    d = new Date();
    t = ((function() {
      var j, len, ref1, results;
      ref1 = [d.getHours(), d.getMinutes(), d.getSeconds()];
      results = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        a = ref1[j];
        results.push(a < 10 ? '0' + a : a);
      }
      return results;
    })()).join(':');
    arr = ["[" + t + "]"];
    switch (type) {
      case 'default':
        null;
        break;
      case 'success':
      case 'done':
      case 'ok':
        arr.push("<" + (type.toUpperCase()) + ">");
        break;
      case 'fail':
      case 'error':
      case 'fatal':
        arr.push("<" + (type.toUpperCase()) + ">");
        break;
      default:
        arr.push("<" + (type.toUpperCase()) + ">");
    }
    arr.push(msg);
    $.log(arr.join(' '));
    return msg;
  };

  $.i = function(msg) {
    $.log(msg);
    return msg;
  };

  $.timeStamp = function(param) {
    var a, b, c, d, i, j, p;
    switch ($.type(p = param)) {
      case 'number':
        return p;
      case 'string':
        if (!~p.search(/[\s\.\-\/]/)) {
          return $.now();
        }
        if (~p.search(/\:/)) {
          a = p.split(' ');
          if (!~a[0].search(/\:/)) {
            b = a[0].replace(/[\-\/]/g, '.').split('.');
            c = a[1].split(':');
          } else {
            b = a[1].replace(/[\-\/]/g, '.').split('.');
            c = a[0].split(':');
          }
        } else {
          b = p.replace(/[\-\/]/g, '.').split('.');
          c = [0, 0, 0];
        }
        for (i = j = 0; j <= 2; i = ++j) {
          b[i] = parseInt(b[i]);
          c[i] = parseInt(c[i] || 0);
        }
        d = new Date();
        d.setFullYear(b[0], b[1] - 1, b[2]);
        d.setHours(c[0], c[1], c[2]);
        return parseInt(d.getTime() / 1e3) * 1e3;
      default:
        return $.now();
    }
  };

  $.timeString = function(time) {
    var d, fn;
    d = time ? new Date(time) : new Date();
    fn = function(n) {
      if (n < 10) {
        return '0' + n;
      } else {
        return n;
      }
    };
    return [fn(d.getHours()), fn(d.getMinutes()), fn(d.getSeconds())].join(':');
  };

  $.shell = function(cmd, callback) {
    var child, fn;
    fn = $.shell;
    fn.platform || (fn.platform = (require('os')).platform());
    fn.exec || (fn.exec = (require('child_process')).exec);
    fn.info || (fn.info = function(string) {
      var text;
      text = $.trim(string);
      if (!text.length) {
        return;
      }
      return $.log(text.replace(/\r/g, '\n').replace(/\n{2,}/g, ''));
    });
    if ($.type(cmd) === 'array') {
      cmd = fn.platform === 'win32' ? cmd.join('&') : cmd.join('&&');
    }
    $.info('shell', cmd);
    child = fn.exec(cmd);
    child.stdout.on('data', function(data) {
      return fn.info(data);
    });
    child.stderr.on('data', function(data) {
      return fn.info(data);
    });
    return child.on('close', function() {
      return typeof callback === "function" ? callback() : void 0;
    });
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

}).call(this);
