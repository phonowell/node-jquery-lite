(function(){var $,_,domain,parseType,request,slice=[].slice,indexOf=[].indexOf||function(e){for(var r=0,t=this.length;t>r;r++)if(r in this&&this[r]===e)return r;return-1};_=require("lodash"),module.exports=$={version:"0.3.2",startTime:_.now()},domain=require("domain"),process.on("uncaughtException",function(e){return $.info("fatal",e),$.log(e.stack)}),$["try"]=function(){var e,r,t;return r=1<=arguments.length?slice.call(arguments,0):[],e=r,t={_domain:domain.create()},t["try"]=function(e){return $.next(function(){return t._domain.run(e)}),t},t["catch"]=function(e){return t._catch=e,t},t._domain.on("error",function(e){return $.info("error",e),"function"==typeof t._catch?t._catch(e):void 0}),"function"===$.type(e[0])&&t["try"](e[0]),"function"===$.type(e[1])&&t["catch"](e[1]),t},$.extend=_.extend,$.param=require("querystring").stringify,$.trim=_.trim,$.now=_.now,$.type=function(e){var r;return r=Object.prototype.toString.call(e).replace(/^\[object\s(.+)\]$/,"$1").toLowerCase(),"uint8array"===r?"buffer":r},$.noop=_.noop,$.Callbacks=function(){var e,r;return r={_status:{fired:!1},_list:[]},e=r._list,r.add=function(){var t,n,a,u;for(u=1<=arguments.length?slice.call(arguments,0):[],n=0,a=u.length;a>n;n++)t=u[n],e.push(t);return r},r.remove=function(t){return _.remove(e,t),r},r.has=function(r){return indexOf.call(e,r)>=0},r.empty=function(){return e=[],r},r.fire=function(){var t,n,a,u;for(u=1<=arguments.length?slice.call(arguments,0):[],n=0,a=e.length;a>n;n++)t=e[n],"function"==typeof t&&t.apply(null,u);return r._status.fired=!0,r},r.fired=function(){return r._status.fired},r},$.Deferred=function(){var e,r;return r={_list:{done:$.Callbacks(),fail:$.Callbacks()}},e=r._list,r.done=function(t){return e.done.add(t),r},r.fail=function(t){return e.fail.add(t),r},r.resolve=function(){var t,n;return t=1<=arguments.length?slice.call(arguments,0):[],(n=e.done).fire.apply(n,t),r},r.reject=function(){var t,n;return t=1<=arguments.length?slice.call(arguments,0):[],(n=e.fail).fire.apply(n,t),r},r},$.parseTime=function(e){return $.parseTime.trans($.timeStamp(e))},$.parseTime.trans=function(e){var r,t,n,a,u,i,s,o,c,l,f,g;return t=new Date(e),l=t.getTime(),n=new Date,g=n.getTime(),f=g-l,u=t.getHours()+"时"+(t.getMinutes()<10?"0":"")+t.getMinutes()+"分",i=t.getMonth()+1+"月"+t.getDate()+"日(星期"+["日","一","二","三","四","五","六"][t.getDay()]+") "+u,s=t.getFullYear()+"年"+i,0>f?"刚刚":f/1e3/60/60/24/365|0?s:(r=f/1e3/60/60/24)>3?t.getFullYear()!==n.getFullYear()?s:i:(r=(n.getDay()-t.getDay()+7)%7)>2?i:r>1?"前天 "+u:(a=f/1e3/60/60)>12?(t.getDay()!==n.getDay()?"昨天 ":"今天 ")+u:(a=f/1e3/60/60%60|0)?a+"小时前":(o=f/1e3/60%60|0)?o+"分钟前":(c=f/1e3%60|0)>30?c+"秒前":"刚刚"},$.parseString=function(e){var r,t,n;switch($.type(r=e)){case"string":return r;case"number":return r.toString();case"array":return JSON.stringify({_obj:r}).replace(/\{(.*)\}/,"$1").replace(/"_obj":/,"");case"object":return JSON.stringify(r);case"boolean":return r.toString();case"undefined":return"undefined";case"null":return"null";default:try{return r.toString()}catch(n){return t=n,""}}},$.parsePts=function(e){var r;return(r=0|(e||0))>=1e5?(.001*r|0)/10+"万":r.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")},$.parseJson=$.parseJSON=function(data){var d,fn;switch(d=data,fn=function(p){var e,error,res;try{switch(res=eval("("+p+")"),$.type(res)){case"object":case"array":return res;default:return null}}catch(error){return e=error,null}},$.type(d)){case"string":return fn(d);case"object":return d;default:return null}},request=require("request"),parseType=function(e){var r;return r=e.headers["content-type"],r&&~r.search(/application\/json/)?"json":"text"},$.get=function(e,r){var t;return t=$.Deferred(),request({method:"GET",url:e,form:r,gzip:!0},function(e,r,n){var a;return e?void t.reject(e):(a=parseType(r),t.resolve("json"===a?$.parseJson(n):n))}),t},$.post=function(e,r){var t;return t=$.Deferred(),request({method:"POST",url:e,form:r,gzip:!0},function(e,r,n){var a;return e?void t.reject(e):(a=parseType(r),t.resolve("json"===a?$.parseJson(n):n))}),t},$.next=function(){var e,r,t,n;return r=1<=arguments.length?slice.call(arguments,0):[],t=r[1]?r:[0,r[0]],n=t[0],e=t[1],n?void setTimeout(e,n):process.nextTick(e)},$.log=console.log,$.info=function(){var e,r,t,n,a,u,i,s;return a=1<=arguments.length?slice.call(arguments,0):[],u=a[1]?a:["default",a[0]],s=u[0],n=u[1],t=new Date,i=function(){var r,n,a,u;for(a=[t.getHours(),t.getMinutes(),t.getSeconds()],u=[],r=0,n=a.length;n>r;r++)e=a[r],u.push(10>e?"0"+e:e);return u}().join(":"),r=["["+i+"]"],"default"!==s&&r.push("<"+s.toUpperCase()+">"),r.push(n),$.log(r.join(" ")),n},$.i=function(e){return $.log(e),e},$.timeStamp=function(e){var r,t,n,a,u,i,s;switch($.type(s=e)){case"number":return s;case"string":if(!~s.search(/[\s\.\-\/]/))return $.now();for(~s.search(/\:/)?(r=s.split(" "),~r[0].search(/\:/)?(t=r[1].replace(/[\-\/]/g,".").split("."),n=r[0].split(":")):(t=r[0].replace(/[\-\/]/g,".").split("."),n=r[1].split(":"))):(t=s.replace(/[\-\/]/g,".").split("."),n=[0,0,0]),u=i=0;2>=i;u=++i)t[u]=parseInt(t[u]),n[u]=parseInt(n[u]||0);return a=new Date,a.setFullYear(t[0],t[1]-1,t[2]),a.setHours(n[0],n[1],n[2]),1e3*parseInt(a.getTime()/1e3);default:return $.now()}},$.rnd=function(){var e,r;switch(e=1<=arguments.length?slice.call(arguments,0):[],r=Math.random(),e.length){case 1:switch($.type(e[0])){case"number":return r*e[0]|0;case"array":return e[0][r*e[0].length|0]}break;case 2:return e[0]+r*(e[1]-e[0])|0;default:return 2*r|0}},$.timeString=function(e){var r,t;return r=e?new Date(e):new Date,t=function(e){return 10>e?"0"+e:e},[t(r.getHours()),t(r.getMinutes()),t(r.getSeconds())].join(":")}}).call(this);