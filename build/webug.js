(function(){!function(win,doc){"user strict";var Stack,Webug;return function(){var t,e,n;return e=doc.createElement("link"),n=doc.createElement("script"),t=doc.createElement("script"),e.setAttribute("rel","styleSheet"),e.setAttribute("href","bootstrap/css/bootstrap.min.css"),n.src="jquery.min.js",n.onload=n.readyreadystatechange=function(){return!n.readyState||/loaded|complete/.test(n.readyState)?(console.log("jq ok"),doc.body.appendChild(t)):void 0},t.src="bootstrap/js/bootstrap.min.js",t.onload=t.readyreadystatechange=function(){var e;return!t.readyState||/loaded|complete/.test(t.readyState)?(console.log("load ok"),t.onload=t.readystatechange=null,e=new Webug):void 0},doc.body.appendChild(e),doc.body.appendChild(n)}(),Stack=function(){function t(){this.data=[],this.index=0}return t.prototype.push=function(t){return this.data.push(t),this.index=this.data.length-1},t.prototype.up=function(){return 0!==this.index?this.data[this.index--]:this.data[this.index]},t.prototype.down=function(){return this.index!==this.data.length-1?this.data[this.index++]:this.data[this.index]},t}(),Webug=function(){function Webug(){this.isInit=!1,this.isHide=!1,this.msg="",this.body=getBody(),this.stack=new Stack,this.init(),this.isInit=!0}var CHANGE,CLICK,ERROR,HTML,INPUT,KEYDOWN,MOUSEDOWN,MOUSEMOVE,MOUSEUP,TRUE,UNDEFINED,bind,createLiEle,enumerable,enumerableAndNotEnumerable,getAttrs,getBody,getPropertyName,isArray,isFunction,isNull,isNumber,isObejct,notEnumerable,unbind;return HTML='<div id="webug-up" class="progress" style="margin:0;height:8px"> <div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 100%;"> </div> </div> <div id="webug-container" class="panel panel-default" style="padding-top:5px;margin:0;"> <div class="btn-group pull-right" role="group" aria-label="..."> <button id="webug-clear" type="button" class="btn btn-info btn-sm"> <span class="glyphicon glyphicon-refresh" aria-hidden="true"></span> </button> <button id="webug-close" type="button" class="btn btn-danger btn-sm"> <span class="glyphicon glyphicon-remove-sign" aria-hidden="true"></span></button> </button> </div> <ul id="webug-ul" class="list-group" style="height:150px;overflow-y:scroll;margin: 40px 0 10px"></ul> <div class="input-group input-group-bg"> <span class="input-group-addon ">></span> <input id="webug-input" type="text" class="form-control" placeholder="" aria-describedby="sizing-addon3"> </div> <select id="webug-select" class="form-control" size="" style="width:200px;position:fixed;bottom:40px;left:50px;display:none"></select> </div>',UNDEFINED=void 0,CLICK="click ",KEYDOWN="keydown ",TRUE="true ",ERROR="error ",INPUT="input ",CHANGE="change ",MOUSEUP="mouseup ",MOUSEDOWN="mousedown ",MOUSEMOVE="mousemove ",bind=function(t,e,n){return $(t).on(e,function(t){return n(t)})},unbind=function(t,e,n){},isNull=function(t){return null===t},isArray=Array.isArray,isNumber=function(t){return!isNaN(t)},isObejct=function(t){return"object"==typeof t&&!isFunction(t)&&!isNull(t)},isFunction=function(t){return"function"==typeof t},getBody=function(){return $("body")},getAttrs=function(t){var e,n;if(isObejct(t)){e=[];for(n in t)e.push(n);return console.log(t),e}return[]},enumerable=function(t,e){return t.propertyIsEnumerable(e)},notEnumerable=function(t,e){return!t.propertyIsEnumerable(e)},enumerableAndNotEnumerable=function(){return!0},getPropertyName=function(t,e,n,i){var r,s,o,u,l;for(u=[];!!t==!0;){if(e===!0)for(l=Object.getOwnPropertyNames(t),r=0,s=l.length;s>r;r++)o=l[r],u.indexOf(-1===o&&i(t,o))&&u.push(o);if(n===!1)break;e=!0,t=Object.getPrototypeOf(t)}return u},createLiEle=function(t,e){var n,i,r;return i=$('<li style="padding:5px 15px"></li>'),r='<span class="glyphicon glyphicon-menu-right"></span><span style="margin-left:16px">',n="list-group-item ",e===!1?(n+="text-danger ",r='<span class="glyphicon glyphicon-remove"></span><span style="margin-left:16px">'):"result"===e&&(r='<span style="margin-left:30px"></span><span>'),r+=t+"</span>",i.html(r),i.addClass(n),i},Webug.prototype.render=function(t,e){var n,i,r;if(""===t)return[!0,""];null==e&&this.append(!0,t);try{return n=eval.call(win,t),["result",isObejct(n)?JSON.stringify(n):isFunction(n)?n.toString?n.toString():n.valueOf?n.valueOf():void 0:n]}catch(r){return i=r,[!1,i]}},Webug.prototype.append=function(t,e){var n;return""!==e?(n=createLiEle(e,t),this.ul.append(n),this.scrollBottom()):void 0},Webug.prototype.clear=function(){return this.ul.empty()},Webug.prototype.show=function(){return this.isHide=!1,this.container.show()},Webug.prototype.hide=function(){return this.isHide=!0,this.container.hide()},Webug.prototype.searchAttribute=function(t,e){var n,i,r,s,o;for(n=[],i=getPropertyName(e,!0,!0,enumerableAndNotEnumerable()),r=0,o=i.length;o>r;r++)s=i[r],0===s.indexOf(t)&&n.push(s);return n},Webug.prototype.appendInSelect=function(t){var e,n,i,r,s;for(e="",n=0,i=t.length;i>n;n++)s=t[n],e+="<option>"+s+"</option>";return this.select.html(e),r=t.length>8?8:t.length+1,this.select.attr("size",r),this.controlSelectPos(),1===r?this.select.hide():this.select.show()},Webug.prototype.clearSelect=function(){return this.select.html(""),this.select.hide()},Webug.prototype.clearInput=function(){return this.input.val("")},Webug.prototype.controlSelectPos=function(){return this.select.css("left",5*this.input.val().length+50+"px")},Webug.prototype.inputListner=function(e){var env,pos,tmp,val;return val=this.input.val(),0===val.length?this.select.hide():(pos=val.lastIndexOf("."),-1===pos?(env=win,this.env=""):(tmp=val.substring(0,pos),this.env=tmp+".",env=eval(tmp)),val=val.substring(pos+1,val.length),this.appendInSelect(this.searchAttribute(val,env)))},Webug.prototype.scrollBottom=function(){return this.ul.scrollTop(this.ul.prop("scrollHeight"))},Webug.prototype.selectPos=function(){return this.select},Webug.prototype.init=function(){var t;return this.isHide=!1,this.env="",t=$('<div style="position:fixed;bottom:0;left:0;"></div>'),t.html(HTML),this.body.append(t),this.container=$("#webug-container"),this.btn_clear=$("#webug-clear"),this.btn_close=$("#webug-close"),this.input=$("#webug-input"),this.ul=$("#webug-ul"),this.select=$("#webug-select"),this.div_up=$("#webug-up"),this.is_Mouse_Down=!1,bind(this.div_up,MOUSEDOWN,function(t){return function(e){return t.src_pos_y=e.pageY,t.is_Mouse_Down=!0}}(this)),bind(doc,CLICK+MOUSEUP,function(t){return function(e){return t.is_Mouse_Down===!0?t.is_Mouse_Down=!1:void 0}}(this)),bind(doc,MOUSEMOVE,function(t){return function(e){var n;return t.is_Mouse_Down===!0?(t.dest_pos_y=e.pageY,n=t.src_pos_y-t.dest_pos_y,t.src_pos_y=t.dest_pos_y,t.ul.height(t.ul.height()+n)):void 0}}(this)),bind(this.btn_clear,CLICK,function(t){return function(){return t.clear()}}(this)),bind(this.btn_close,CLICK,function(t){return function(){return t.hide()}}(this)),bind(this.input,KEYDOWN,function(t){return function(e){var n;return 13===e.keyCode?(t.msg=t.input.val(),t.stack.push(t.msg),n=t.render(t.msg),t.append(n[0],n[1]),t.clearInput(),t.clearSelect()):38===e.keyCode?t.select.is(":hidden")?(t.input.val(t.stack.up()),t.input.prop("selectionStart",t.input.val().length),e.preventDefault()):t.select.focus():40===e.keyCode?t.select.is(":hidden")?(t.input.val(t.stack.down()),t.input.prop("selectionStart",t.input.val().length),e.preventDefault()):t.select.focus():void 0}}(this)),bind(this.input,INPUT,function(t){return function(e){return t.inputListner(e)}}(this)),bind(this.select,KEYDOWN,function(t){return function(e){return 13===e.keyCode?(t.input.val(t.env+t.select.val()),t.input.focus(),t.clearSelect()):37===e.keyCode?(t.input.focus(),e.preventDefault()):void 0}}(this)),bind(this.select,CLICK,function(t){return function(e){return t.input.val(t.select.val()),t.input.focus()}}(this)),bind(this.body,KEYDOWN,function(t){return function(e){return 88===e.keyCode&&e.ctrlKey?t.isHide?t.show():t.hide():void 0}}(this))},Webug}()}(window,document)}).call(this);