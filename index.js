(function(){var $,_,domain,http,https,slice=[].slice,indexOf=[].indexOf||function(e){for(var t=0,r=this.length;r>t;t++)if(t in this&&this[t]===e)return t;return-1};_=require("lodash"),module.exports=$={version:"0.3.1",startTime:_.now()},$.env=(process.env.NODE_ENV||"production").toLowerCase(),$.debug="development"===$.env?!0:!1,domain=require("domain"),process.on("uncaughtException",function(e){return $.info("fatal",e),$.log(e.stack)}),$["try"]=function(){var e,t,r;return t=1<=arguments.length?slice.call(arguments,0):[],e=t,r={_domain:domain.create()},r["try"]=function(e){return $.next(function(){return r._domain.run(e)}),r},r["catch"]=function(e){return r._catch=e,r},r._domain.on("error",function(e){return $.info("error",e),"function"==typeof r._catch?r._catch(e):void 0}),"function"===$.type(e[0])&&r["try"](e[0]),"function"===$.type(e[1])&&r["catch"](e[1]),r},$.extend=_.extend,$.param=require("querystring").stringify,$.trim=_.trim,$.now=_.now,$.type=function(e){var t,r;switch(t=e,r=typeof t){case"object":return t?"[object Array]"===toString.call(t)?"array":"[object Date]"===toString.call(t)?"date":"[object Error]"===toString.call(t)?"error":t.fill?"buffer":"object":null===t?"null":"undefined";case"number":return t!==+t?"NaN":r;default:return r}},$.noop=_.noop,$.Callbacks=function(){var e,t;return t={_status:{fired:!1},_list:[]},e=t._list,t.add=function(){var r,n,a,u;for(u=1<=arguments.length?slice.call(arguments,0):[],n=0,a=u.length;a>n;n++)r=u[n],e.push(r);return t},t.remove=function(r){var n,a,u,i;for(a=u=0,i=e.length;i>u;a=++u)if(n=e[a],n===r){e.splice(a,1);break}return t},t.has=function(t){return indexOf.call(e,t)>=0},t.empty=function(){return e=[],t},t.fire=function(){var r,n,a,u;for(u=1<=arguments.length?slice.call(arguments,0):[],n=0,a=e.length;a>n;n++)r=e[n],"function"==typeof r&&r.apply(null,u);return t._status.fired=!0,t},t.fired=function(){return t._status.fired},t},$.Deferred=function(){var e,t;return t={_list:{done:$.Callbacks(),fail:$.Callbacks()}},e=t._list,t.done=function(r){return e.done.add(r),t},t.fail=function(r){return e.fail.add(r),t},t.resolve=function(){var r,n;return r=1<=arguments.length?slice.call(arguments,0):[],(n=e.done).fire.apply(n,r),t},t.reject=function(){var r,n;return r=1<=arguments.length?slice.call(arguments,0):[],(n=e.fail).fire.apply(n,r),t},t},$.parseTime=function(e){return $.parseTime.trans($.timeStamp(e))},$.parseTime.trans=function(e){var t,r,n,a,u,i,o,s,c,l,f,g;return r=new Date(e),l=r.getTime(),n=new Date,g=n.getTime(),f=g-l,u=r.getHours()+"时"+(r.getMinutes()<10?"0":"")+r.getMinutes()+"分",i=r.getMonth()+1+"月"+r.getDate()+"日(星期"+["日","一","二","三","四","五","六"][r.getDay()]+") "+u,o=r.getFullYear()+"年"+i,0>f?"刚刚":f/1e3/60/60/24/365|0?o:(t=f/1e3/60/60/24)>3?r.getFullYear()!==n.getFullYear()?o:i:(t=(n.getDay()-r.getDay()+7)%7)>2?i:t>1?"前天 "+u:(a=f/1e3/60/60)>12?(r.getDay()!==n.getDay()?"昨天 ":"今天 ")+u:(a=f/1e3/60/60%60|0)?a+"小时前":(s=f/1e3/60%60|0)?s+"分钟前":(c=f/1e3%60|0)>30?c+"秒前":"刚刚"},$.parseString=function(e){var t,r,n;switch($.type(t=e)){case"string":return t;case"number":return t.toString();case"array":return JSON.stringify({_obj:t}).replace(/\{(.*)\}/,"$1").replace(/"_obj":/,"");case"object":return JSON.stringify(t);case"boolean":return t.toString();case"undefined":return"undefined";case"null":return"null";default:try{return t.toString()}catch(n){return r=n,""}}},$.parsePts=function(e){var t;return(t=0|(e||0))>=1e5?(.001*t|0)/10+"万":t.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")},$.parseJson=$.parseJSON=function(data){var d,fn;switch(d=data,fn=function(p){var e,error,res;try{switch(res=eval("("+p+")"),$.type(res)){case"object":case"array":return res;default:return null}}catch(error){return e=error,null}},$.type(d)){case"string":return fn(d);case"object":return d;default:return null}},http=require("http"),https=require("https"),$.get=function(){var e,t,r,n,a,u;return n=1<=arguments.length?slice.call(arguments,0):[],r=n,e=~r[0].search("https://")?https:http,u=r[0]+(r[1]?"?"+$.param(r[1]):""),a=e.get(u,function(e){var r,n;return r=[],n=0,e.on("data",function(e){return r.push(e),n+=e.length}).on("end",function(){return r=Buffer.concat(r,n).toString(),t.resolve(r)})}),a.on("error",function(e){return t.reject(e)}),t=$.Deferred()},$.post=function(){var e,t,r,n,a,u,i;return u=1<=arguments.length?slice.call(arguments,0):[],a=u,e=~a[0].search("https://")?https:http,n=function(){var e,t,r,n,u,i;return u=a[0].split("//"),n=~u[0].search("https")?"https":void 0,i=u[1].indexOf("/"),0>i&&(i=u[1].length),e=u[1].slice(0,i),t=u[1].slice(i)||"/",e=e.split(":"),r=e[1]||80,e=e[0],[n,e,t,r]}(),t=$.param(a[1]),i=e.request({host:n[1],port:n[3],method:"POST",path:n[2],headers:{"Content-Type":"application/x-www-form-urlencoded"}},function(e){var t;return t="",e.on("data",function(e){return t.push(e),len+=e.length}).on("end",function(){return t=Buffer.concat(t,len).toString(),r.resolve(t)})}),i.write(t),i.end(),i.on("error",function(e){return r.reject(e)}),r=$.Deferred()},$.next=function(){var e,t,r,n;return t=1<=arguments.length?slice.call(arguments,0):[],r=t[1]?t:[0,t[0]],n=r[0],e=r[1],n?void setTimeout(e,n):process.nextTick(e)},$.log=console.log,$.info=function(){var e,t,r,n,a,u,i,o;return a=1<=arguments.length?slice.call(arguments,0):[],u=a[1]?a:["default",a[0]],o=u[0],n=u[1],r=new Date,i=function(){var t,n,a,u;for(a=[r.getHours(),r.getMinutes(),r.getSeconds()],u=[],t=0,n=a.length;n>t;t++)e=a[t],u.push(10>e?"0"+e:e);return u}().join(":"),t=["["+i+"]"],"default"!==o&&t.push("<"+o.toUpperCase()+">"),t.push(n),$.log(t.join(" ")),n},$.i=function(e){return $.log(e),e},$.timeStamp=function(e){var t,r,n,a,u,i,o;switch($.type(o=e)){case"number":return o;case"string":if(!~o.search(/[\s\.\-\/]/))return $.now();for(~o.search(/\:/)?(t=o.split(" "),~t[0].search(/\:/)?(r=t[1].replace(/[\-\/]/g,".").split("."),n=t[0].split(":")):(r=t[0].replace(/[\-\/]/g,".").split("."),n=t[1].split(":"))):(r=o.replace(/[\-\/]/g,".").split("."),n=[0,0,0]),u=i=0;2>=i;u=++i)r[u]=parseInt(r[u]),n[u]=parseInt(n[u]||0);return a=new Date,a.setFullYear(r[0],r[1]-1,r[2]),a.setHours(n[0],n[1],n[2]),1e3*parseInt(a.getTime()/1e3);default:return $.now()}},$.rnd=function(){var e,t;switch(e=1<=arguments.length?slice.call(arguments,0):[],t=Math.random(),e.length){case 1:switch($.type(e[0])){case"number":return t*e[0]|0;case"array":return e[0][t*e[0].length|0]}break;case 2:return e[0]+t*(e[1]-e[0])|0;default:return 2*t|0}},$.timeString=function(e){var t,r;return t=e?new Date(e):new Date,r=function(e){return 10>e?"0"+e:e},[r(t.getHours()),r(t.getMinutes()),r(t.getSeconds())].join(":")}}).call(this);