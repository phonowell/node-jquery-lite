(function(){var $,Callbacks,Deferred,_,parseType,request,slice=[].slice,indexOf=[].indexOf||function(t){for(var e=0,r=this.length;e<r;e++)if(e in this&&this[e]===t)return e;return-1};_=require("lodash"),module.exports=$={_:_,version:"0.3.16"},$.extend=_.extend,$.param=require("querystring").stringify,$.trim=_.trim,$.now=_.now,$.each=_.each,$.noop=_.noop,$.type=function(t){var e;return e=Object.prototype.toString.call(t).replace(/^\[object\s(.+)\]$/,"$1").toLowerCase(),"uint8array"===e?"buffer":e},Callbacks=function(){function t(t){this.option=$.extend({once:!1,memory:!1,unique:!1,stopOnFalse:!1},t),this.status={isDisabled:!1,isLocked:!1,isFired:!1},this.list=[]}return t.prototype.add=function(){var t,e,r,n,i;if(e=1<=arguments.length?slice.call(arguments,0):[],this.locked())return this;for(t=function(t){return function(e){if(t.list.push(e),t.option.memory&&t.fired())return e.apply(null,t.args)}}(this),n=0,i=e.length;n<i;n++)r=e[n],"function"===$.type(r)&&(this.option.unique?this.has(r)||t(r):t(r));return this},t.prototype.disable=function(){return this.status.isDisabled=!0,this},t.prototype.disabled=function(){return!!this.status.isDisabled},t.prototype.empty=function(){return this.locked()?this:(this.list=[],this)},t.prototype.fire=function(){var t,e,r,n,i,s;if(t=1<=arguments.length?slice.call(arguments,0):[],this.disabled())return this;if(this.option.once&&this.fired())return this;for(i=this.list,r=0,n=i.length;r<n&&(e=i[r],s=e.apply(null,t),!this.option.stopOnFalse||s!==!1);r++);return this.status.isFired=!0,this.option.memory&&(this.args=t),this},t.prototype.fired=function(){return!!this.status.isFired},t.prototype.fireWith=function(){var t,e,r,n,i,s,o;if(e=arguments[0],t=2<=arguments.length?slice.call(arguments,1):[],this.disabled())return this;if(this.option.once&&this.fired())return this;for(s=this.list,n=0,i=s.length;n<i&&(r=s[n],o=r.apply(e,t),!this.option.stopOnFalse||o!==!1);n++);return this.status.isFired=!0,this},t.prototype.has=function(t){return indexOf.call(this.list,t)>=0},t.prototype.lock=function(){return this.status.isLocked=!0,this},t.prototype.locked=function(){return!!this.status.isLocked},t.prototype.remove=function(t){return this.locked()?this:(_.remove(this.list,function(e){return e===t}),this)},t}(),$.Callbacks=function(){var t;return t=1<=arguments.length?slice.call(arguments,0):[],function(t,e,r){r.prototype=t.prototype;var n=new r,i=t.apply(n,e);return Object(i)===i?i:n}(Callbacks,t,function(){})},Deferred=function(){function t(){this.status={isRejected:!1,isResolved:!1,state:"pending"},this.list={resolve:$.Callbacks({once:!0}),reject:$.Callbacks({once:!0}),notify:$.Callbacks()}}var e;return e=function(t,e){if("function"===$.type(t))return e.add(t)},t.prototype.always=function(t){return this.done(t),this.fail(t)},t.prototype.done=function(t){return e(t,this.list.resolve),this},t.prototype.fail=function(t){return e(t,this.list.reject),this},t.prototype.notify=function(){var t,e;return t=1<=arguments.length?slice.call(arguments,0):[],this.args=t,(e=this.list.notify).fire.apply(e,t),this},t.prototype.notifyWith=function(){var t,e;return t=1<=arguments.length?slice.call(arguments,0):[],this.args=t,(e=this.list.notify).fireWith.apply(e,t),this},t.prototype.progress=function(t){return e(t,this.list.notify),this},t.prototype.promise=function(){return this},t.prototype.reject=function(){var t,e;return t=1<=arguments.length?slice.call(arguments,0):[],this.status.state="rejected",this.args=t,(e=this.list.reject).fire.apply(e,t),this},t.prototype.rejectWith=function(){var t,e;return t=1<=arguments.length?slice.call(arguments,0):[],this.status.state="rejected",this.args=t,(e=this.list.reject).fireWith.apply(e,t),this},t.prototype.resolve=function(){var t,e;return t=1<=arguments.length?slice.call(arguments,0):[],this.status.state="resolved",this.args=t,(e=this.list.resolve).fire.apply(e,t),this},t.prototype.resolveWith=function(){var t,e;return t=1<=arguments.length?slice.call(arguments,0):[],this.status.state="resolved",this.args=t,(e=this.list.resolve).fireWith.apply(e,t),this},t.prototype.state=function(){return this.status.state},t.prototype.then=function(){var t;return t=1<=arguments.length?slice.call(arguments,0):[],this.done(t[0]),this.fail(t[1])},t}(),$.Deferred=function(){return new Deferred},$.when=function(){var t,e,r,n,i,s,o,a,l;for(r=1<=arguments.length?slice.call(arguments,0):[],n=$.Deferred(),l=function(t){return 1===t.length?t[0]:t},a={state:[],def:[]},i=function(t,e){var r,i;return(null!=t&&null!=(r=t.status)?r.state:void 0)?(i=t.status.state,"resolved"===i?(a.state[e]="resolved",void(a.def[e]=l(t.args))):"rejected"===i?(a.state=null,void(a.def=t.args)):(a.state[e]="pending",t.done(function(){var t;return t=1<=arguments.length?slice.call(arguments,0):[],n.notify(e,"resolved",t)}).fail(function(){var t;return t=1<=arguments.length?slice.call(arguments,0):[],n.reject.apply(n,t)}))):(a.state[e]="resolved",void(a.def[e]=t))},e=s=0,o=r.length;s<o&&(t=r[e],i(t,e),a.state);e=++s);return a.state?indexOf.call(a.state,"pending")>=0?(n.progress(function(t,e,r){if(a.state[t]=e,a.def[t]=l(r),!(indexOf.call(a.state,"pending")>=0))return n.resolve.apply(n,a.def)}),n.promise()):($.next(function(){return n.resolve.apply(n,a.def)}),n.promise()):($.next(function(){return n.reject.apply(n,a.def)}),n.promise())},$.parseTime=function(t,e){return $.parseTime.trans($.timeStamp(t),e)},$.parseTime.trans=function(t,e){var r,n,i,s,o,a,l,u,c,p,f,h,d;if(n=new Date(t),f=n.getTime(),i=new Date,d=i.getTime(),h=d-f,o=n.getHours()+"时"+(n.getMinutes()<10?"0":"")+n.getMinutes()+"分",l=n.getMonth()+1+"月"+n.getDate()+"日(星期"+["日","一","二","三","四","五","六"][n.getDay()]+") "+o,u=n.getFullYear()+"年"+l,a=0,h<0){if(!e)return"刚刚";a=1}return a&&(h=-h+500),h/31536e6|0?u:(r=h/864e5)>3?n.getFullYear()!==i.getFullYear()?u:l:r>1?["前天 ","后天 "][a]+o:(s=h/36e5)>12?(n.getDay()!==i.getDay()?["昨天 ","明天 "][a]:"今天 ")+o:(s=h/36e5%60|0)?s+["小时前","小时后"][a]:(c=h/6e4%60|0)?c+["分钟前","分钟后"][a]:(p=h/1e3%60|0)>30?p+["秒前","秒后"][a]:"刚刚"},$.parseShortDate=function(t){var e,r,n,i,s,o;for(n="date"===$.type(t)?t:new Date(t),r=[n.getFullYear(),1+n.getMonth(),n.getDate()],i=s=0,o=r.length;s<o;i=++s)e=r[i],r[i]=$.parseString(e),i&&r[i].length<2&&(r[i]="0"+r[i]);return r.join("")},$.parseString=function(t){var e;switch($.type(e=t)){case"string":return e;case"array":return JSON.stringify({_obj:e}).replace(/\{(.*)\}/,"$1").replace(/"_obj":/,"");case"object":return JSON.stringify(e);default:return String(e)}},$.parsePts=function(t){var e;return(e=0|(t||0))>=1e5?(.001*e|0)/10+"万":e.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")},$.parseJson=$.parseJSON=function(data){var err,res;if("string"!==$.type(data))return data;try{switch(res=eval("("+data+")"),$.type(res)){case"object":case"array":return res;default:return data}}catch(error){return err=error,data}},$.parseSafe=_.escape,$.parseTemp=function(t,e){var r,n,i;n=t;for(r in e)i=e[r],n=n.replace(new RegExp("\\["+r+"\\]","g"),i);return n},request=require("request"),parseType=function(t){var e;return e=t.headers["content-type"],e&&~e.search(/application\/json/)?"json":"text"},$.get=function(t,e){var r,n,i;return i=$.Deferred(),e&&(n=t.replace(/\?.*/,""),r=$.serialize(t.replace(/.*\?/,"")),_.extend(r,e),t=n+"?"+$.param(r)),request({method:"GET",url:t,gzip:!0},function(t,e,r){var n;return t?void i.reject(t):(n=parseType(e),i.resolve("json"===n?$.parseJson(r):r))}),i.promise()},$.post=function(t,e){var r;return r=$.Deferred(),request({method:"POST",url:t,form:e,gzip:!0},function(t,e,n){var i;return t?void r.reject(t):(i=parseType(e),r.resolve("json"===i?$.parseJson(n):n))}),r.promise()},$.next=function(){var t,e,r,n;return e=1<=arguments.length?slice.call(arguments,0):[],r=e[1]?e:[0,e[0]],n=r[0],t=r[1],n?void setTimeout(t,n):process.nextTick(t)},$.log=console.log,$.info=function(){var t,e,r,n,i,s,o,a;switch(i=1<=arguments.length?slice.call(arguments,0):[],s=i[1]?i:["default",i[0]],a=s[0],n=s[1],r=new Date,o=function(){var e,n,i,s;for(i=[r.getHours(),r.getMinutes(),r.getSeconds()],s=[],e=0,n=i.length;e<n;e++)t=i[e],s.push(t<10?"0"+t:t);return s}().join(":"),e=["["+o+"]"],a){case"default":break;case"success":case"done":case"ok":e.push("<"+a.toUpperCase()+">");break;case"fail":case"error":case"fatal":e.push("<"+a.toUpperCase()+">");break;default:e.push("<"+a.toUpperCase()+">")}return e.push(n),$.log(e.join(" ")),n},$.i=function(t){return $.log(t),t},$.timeStamp=function(t){var e,r,n,i,s,o,a;switch($.type(a=t)){case"number":return a;case"string":if(!~a.search(/[\s\.\-\/]/))return $.now();for(~a.search(/\:/)?(e=a.split(" "),~e[0].search(/\:/)?(r=e[1].replace(/[\-\/]/g,".").split("."),n=e[0].split(":")):(r=e[0].replace(/[\-\/]/g,".").split("."),n=e[1].split(":"))):(r=a.replace(/[\-\/]/g,".").split("."),n=[0,0,0]),s=o=0;o<=2;s=++o)r[s]=parseInt(r[s]),n[s]=parseInt(n[s]||0);return i=new Date,i.setFullYear(r[0],r[1]-1,r[2]),i.setHours(n[0],n[1],n[2]),1e3*parseInt(i.getTime()/1e3);default:return $.now()}},$.timeString=function(t){var e,r;return e=t?new Date(t):new Date,r=function(t){return t<10?"0"+t:t},[r(e.getHours()),r(e.getMinutes()),r(e.getSeconds())].join(":")},$.shell=function(t,e){var r,n;return n=$.shell,n.platform||(n.platform=require("os").platform()),n.exec||(n.exec=require("child_process").exec),n.info||(n.info=function(t){var e;if(e=$.trim(t),e.length)return $.log(e.replace(/\r/g,"\n").replace(/\n{2,}/g,""))}),"array"===$.type(t)&&(t="win32"===n.platform?t.join("&"):t.join("&&")),$.info("shell",t),r=n.exec(t),r.stdout.on("data",function(t){return n.info(t)}),r.stderr.on("data",function(t){return n.info(t)}),r.on("close",function(){return"function"==typeof e?e():void 0})},$.serialize=function(t){var e,r,n,i,s,o,a,l,u;switch($.type(t)){case"object":return t;case"string":if(!~t.search(/=/))return{};for(l={},o=_.trim(t.replace(/\?/g,"")).split("&"),n=0,s=o.length;n<s;n++)e=o[n],r=e.split("="),a=[_.trim(r[0]),_.trim(r[1])],i=a[0],u=a[1],i.length&&(l[i]=u);return l;default:return{}}}}).call(this);