(function(){var $,_,colors,parseType,request,slice=[].slice,indexOf=[].indexOf||function(e){for(var r=0,t=this.length;t>r;r++)if(r in this&&this[r]===e)return r;return-1};_=require("lodash"),colors=require("colors/safe"),module.exports=$={version:"0.3.10",startTime:_.now()},$.extend=_.extend,$.param=require("querystring").stringify,$.trim=_.trim,$.now=_.now,$.type=function(e){var r;return r=Object.prototype.toString.call(e).replace(/^\[object\s(.+)\]$/,"$1").toLowerCase(),"uint8array"===r?"buffer":r},$.noop=_.noop,$.each=_.each,$.Callbacks=function(e){var r,t,n;return e=$.extend({},e),t={},n=t._status={fired:!1},r=t._list=[],t.add=function(){var n,a,s,o;for(n=1<=arguments.length?slice.call(arguments,0):[],s=0,o=n.length;o>s;s++)a=n[s],"function"===$.type(a)&&(e.unique?t.has(a)||r.push(a):r.push(a));return t},t.remove=function(e){return _.remove(r,function(r){return r===e}),t},t.has=function(e){return indexOf.call(r,e)>=0},t.empty=function(){return r=[],t},t.fire=function(){var a,s,o,u;if(a=1<=arguments.length?slice.call(arguments,0):[],e.once&&n.fired)return t;for(o=0,u=r.length;u>o;o++)s=r[o],s.apply(null,a);return n.fired=!0,t},t.fireWith=function(){var a,s,o,u,i;if(s=arguments[0],a=2<=arguments.length?slice.call(arguments,1):[],e.once&&n.fired)return t;for(u=0,i=r.length;i>u;u++)o=r[u],o.apply(s,a);return n.fired=!0,t},t.fired=function(){return n.fired},t},$.Deferred=function(){var e,r,t,n,a,s,o,u;for(o={},u=o._status={state:"pending",_arguments:null},a=o._list={done:$.Callbacks({once:!0}),fail:$.Callbacks({once:!0}),notify:$.Callbacks()},o.promise=function(e){return null!=e?$.extend(e,o):o},o.state=function(){return u.state},s=[["resolve","done","resolved"],["reject","fail","rejected"],["progress","notify"]],r=function(e){var r;return o[e[1]]=function(r){return"function"===$.type(r)&&a[e[1]].add(r),o},r=function(){var r,t,n;return n=arguments[0],r=2<=arguments.length?slice.call(arguments,1):[],e[2]&&(u.state=e[2]),u._arguments=r,(t=a[e[1]])["fire"+(n?"With":"")].apply(t,r),o},o[e[0]]=function(){var e;return e=1<=arguments.length?slice.call(arguments,0):[],r.apply(null,[!1].concat(slice.call(e)))},o[e[0]+"With"]=function(){var e,t;return t=arguments[0],e=2<=arguments.length?slice.call(arguments,1):[],r.apply(null,[!0,t].concat(slice.call(e)))}},t=0,n=s.length;n>t;t++)e=s[t],r(e);return o.then=function(){var e;return e=1<=arguments.length?slice.call(arguments,0):[],o.done(e[0]).fail(e[1])},o.always=function(e){return o.done(e).fail(e)},o},$.when=function(){var e,r,t,n,a,s,o,u,i;for(t=1<=arguments.length?slice.call(arguments,0):[],n=$.Deferred(),i=function(e){return 1===e.length?e[0]:e},u={state:[],args:[]},a=function(e,r){var t,a;return(null!=e&&null!=(t=e._status)?t.state:void 0)?(a=e._status.state,"resolved"===a?(u.state.push(1),void(u.args[r]=i(e._status._arguments))):"rejected"===a?(u.state=null,void(u.args=e._status._arguments)):(u.state.push(0),e.done(function(){var e;return e=1<=arguments.length?slice.call(arguments,0):[],n.progress(r,1,e)}).fail(function(){var e;return e=1<=arguments.length?slice.call(arguments,0):[],n.reject.apply(n,e)}))):(u.state.push(1),void(u.args[r]=e))},r=s=0,o=t.length;o>s&&(e=t[r],a(e,r),u.state);r=++s);return u.state?indexOf.call(u.state,0)>=0?(n.notify(function(e,r,t){return u.state[e]=r,u.args[e]=i(t),indexOf.call(u.state,0)>=0?void 0:n.resolve.apply(n,u.args)}),n.promise()):($.next(function(){return n.resolve.apply(n,u.args)}),n.promise()):($.next(function(){return n.reject.apply(n,u.args)}),n.promise())},$.parseTime=function(e,r){return $.parseTime.trans($.timeStamp(e),r)},$.parseTime.trans=function(e,r){var t,n,a,s,o,u,i,l,c,f,p,g,d;if(n=new Date(e),p=n.getTime(),a=new Date,d=a.getTime(),g=d-p,o=n.getHours()+"时"+(n.getMinutes()<10?"0":"")+n.getMinutes()+"分",i=n.getMonth()+1+"月"+n.getDate()+"日(星期"+["日","一","二","三","四","五","六"][n.getDay()]+") "+o,l=n.getFullYear()+"年"+i,u=0,0>g){if(!r)return"刚刚";u=1}return u&&(g=-g+500),g/31536e6|0?l:(t=g/864e5)>3?n.getFullYear()!==a.getFullYear()?l:i:t>1?["前天 ","后天 "][u]+o:(s=g/36e5)>12?(n.getDay()!==a.getDay()?["昨天 ","明天 "][u]:"今天 ")+o:(s=g/36e5%60|0)?s+["小时前","小时后"][u]:(c=g/6e4%60|0)?c+["分钟前","分钟后"][u]:(f=g/1e3%60|0)>30?f+["秒前","秒后"][u]:"刚刚"},$.parseShortDate=function(e){var r,t,n,a,s,o;for(n="date"===$.type(e)?e:new Date(e),t=[n.getFullYear(),1+n.getMonth(),n.getDate()],a=s=0,o=t.length;o>s;a=++s)r=t[a],t[a]=$.parseString(r),a&&t[a].length<2&&(t[a]="0"+t[a]);return t.join("")},$.parseString=function(e){var r,t,n;switch($.type(r=e)){case"string":return r;case"number":return r.toString();case"array":return JSON.stringify({_obj:r}).replace(/\{(.*)\}/,"$1").replace(/"_obj":/,"");case"object":return JSON.stringify(r);case"boolean":return r.toString();case"undefined":return"undefined";case"null":return"null";default:try{return r.toString()}catch(n){return t=n,""}}},$.parsePts=function(e){var r;return(r=0|(e||0))>=1e5?(.001*r|0)/10+"万":r.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")},$.parseJson=$.parseJSON=function(data){var d,fn;switch(d=data,fn=function(p){var e,error,res;try{switch(res=eval("("+p+")"),$.type(res)){case"object":case"array":return res;default:return null}}catch(error){return e=error,null}},$.type(d)){case"string":return fn(d);case"object":return d;default:return null}},$.parseSafe=_.escape,$.parseTemp=function(e,r){var t,n,a;n=e;for(t in r)a=r[t],n=n.replace(new RegExp("\\["+t+"\\]","g"),a);return n},request=require("request"),parseType=function(e){var r;return r=e.headers["content-type"],r&&~r.search(/application\/json/)?"json":"text"},$.get=function(e,r){var t;return t=$.Deferred(),request({method:"GET",url:e,form:r,gzip:!0},function(e,r,n){var a;return e?void t.reject(e):(a=parseType(r),t.resolve("json"===a?$.parseJson(n):n))}),t},$.post=function(e,r){var t;return t=$.Deferred(),request({method:"POST",url:e,form:r,gzip:!0},function(e,r,n){var a;return e?void t.reject(e):(a=parseType(r),t.resolve("json"===a?$.parseJson(n):n))}),t},$.next=function(){var e,r,t,n;return r=1<=arguments.length?slice.call(arguments,0):[],t=r[1]?r:[0,r[0]],n=t[0],e=t[1],n?void setTimeout(e,n):process.nextTick(e)},$.log=console.log,$.info=function(){var e,r,t,n,a,s,o,u;switch(a=1<=arguments.length?slice.call(arguments,0):[],s=a[1]?a:["default",a[0]],u=s[0],n=s[1],t=new Date,o=function(){var r,n,a,s;for(a=[t.getHours(),t.getMinutes(),t.getSeconds()],s=[],r=0,n=a.length;n>r;r++)e=a[r],s.push(10>e?"0"+e:e);return s}().join(":"),r=["["+colors.gray(o)+"]"],u){case"default":break;case"success":case"done":case"ok":r.push("<"+colors.green(u.toUpperCase())+">");break;case"fail":case"error":case"fatal":r.push("<"+colors.red(u.toUpperCase())+">");break;default:r.push("<"+colors.cyan(u.toUpperCase())+">")}return r.push(n),$.log(r.join(" ")),n},$.i=function(e){return $.log(colors.red(e)),e},$.timeStamp=function(e){var r,t,n,a,s,o,u;switch($.type(u=e)){case"number":return u;case"string":if(!~u.search(/[\s\.\-\/]/))return $.now();for(~u.search(/\:/)?(r=u.split(" "),~r[0].search(/\:/)?(t=r[1].replace(/[\-\/]/g,".").split("."),n=r[0].split(":")):(t=r[0].replace(/[\-\/]/g,".").split("."),n=r[1].split(":"))):(t=u.replace(/[\-\/]/g,".").split("."),n=[0,0,0]),s=o=0;2>=o;s=++o)t[s]=parseInt(t[s]),n[s]=parseInt(n[s]||0);return a=new Date,a.setFullYear(t[0],t[1]-1,t[2]),a.setHours(n[0],n[1],n[2]),1e3*parseInt(a.getTime()/1e3);default:return $.now()}},$.rnd=function(){var e,r;switch(e=1<=arguments.length?slice.call(arguments,0):[],r=Math.random(),e.length){case 1:switch($.type(e[0])){case"number":return r*e[0]|0;case"array":return e[0][r*e[0].length|0]}break;case 2:return e[0]+r*(e[1]-e[0])|0;default:return 2*r|0}},$.timeString=function(e){var r,t;return r=e?new Date(e):new Date,t=function(e){return 10>e?"0"+e:e},[t(r.getHours()),t(r.getMinutes()),t(r.getSeconds())].join(":")},$.shell=function(e,r){var t,n;return n=$.shell,n.platform||(n.platform=require("os").platform()),n.exec||(n.exec=require("child_process").exec),n.info||(n.info=function(e){var r;return r=$.trim(e),r.length?$.log(r.replace(/\r/g,"\n").replace(/\n{2,}/g,"")):void 0}),"array"===$.type(e)&&(e="win32"===n.platform?e.join("&"):e.join("&&")),$.info("shell",colors.magenta(e)),t=n.exec(e),t.stdout.on("data",function(e){return n.info(e)}),t.stderr.on("data",function(e){return n.info(e)}),t.on("close",function(){return"function"==typeof r?r():void 0})}}).call(this);