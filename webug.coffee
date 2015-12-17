
# webug.js 0.0.1

((win, doc) ->

  "user strict"

  # 同步加载相关资源
  (() ->
      css = doc.createElement 'link'
      jq = doc.createElement 'script'
      bt = doc.createElement 'script'
      css.setAttribute 'rel', 'styleSheet'
      css.setAttribute 'href', 'bootstrap/css/bootstrap.min.css'
      jq.src = 'jquery-1.11.3.min.js'
      jq.onload = jq.readyreadystatechange = () ->
          if !jq.readyState || /loaded|complete/.test(jq.readyState)
            console.log('jq ok');
            doc.body.appendChild(bt)
      bt.src = 'bootstrap/js/bootstrap.min.js'
      bt.onload = bt.readyreadystatechange = () ->
        if !bt.readyState || /loaded|complete/.test(bt.readyState)
          console.log('load ok');
          bt.onload = bt.readystatechange = null
          webug = new Webug
      doc.body.appendChild(css)
      doc.body.appendChild(jq)
  )()


  # 暂存执行语句
  class Stack
    constructor: ->
      @data = []
      # 指针
      @index = 0

    push: (msg) ->
      @data.push msg
      @index = @data.length - 1

    up: () ->
      if @index isnt 0
        @data[--@index]
      else
        @data[@index]

    down: () ->
      if @index isnt (@data.length - 1)
        @data[++@index]
      else
        @data[@index]

  class Webug
    # 模板HTML
    HTML = '
          <div id="webug-container" class="panel panel-default" style="position:fixed;bottom:0;left:0;padding-top:10px;margin:0;height=200px">
                  <div class="btn-group pull-right" role="group" aria-label="...">
                      <button id="webug-clear" type="button" class="btn btn-info">
                          <span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>
                      </button>
                      <button id="webug-close" type="button" class="btn btn-danger">
                          <span class="glyphicon glyphicon-remove-sign" aria-hidden="true"></span></button>
                      </button>
                  </div>
                  <ul id="webug-ul" class="list-group" style="margin: 10px 0">
                  </ul>
                  <div class="input-group input-group-bg">
                      <span class="input-group-addon ">></span>
                      <input id="webug-input" type="text" class="form-control" placeholder="" aria-describedby="sizing-addon3">
                  </div>
                  <div class="col-xs-2">
                  <select id="webug-select" class="form-control">
                  </select>
                  </div>
          </div>
     '

    UNDEFINED = undefined
    CLICK = 'click'
    KEYDOWN = 'keydown'
    TRUE = 'true'
    ERROR = 'error'
    INPUT = 'input'
    CHANGE = 'change'

    dom = (ele) ->
      doc.querySelector ele

    # 绑定事件
    bind = (ele, event, callback) ->
      ele.addEventListener event,callback, no

    # 解除绑定事件
    unbind = (ele, event, callback) ->
      ele.removeEventListener event, callback, no

    isNull = (val) -> val is null

    isArray = Array.isArray

    isNumber = (val) ->
        !isNaN(val)

    isObejct = (val) ->
      typeof val is "object" and not isArray(val) and not isNull(val)

    getBody = -> doc.body or dom("body") or dom("html")

    # 获取对象的属性名字
    getAttrs = (obj) ->
      if not isObejct obj
        []
      else
        attr = []
        for tmp of obj
          attr.push tmp
        console.log(obj)
        attr

    enumerable = (obj, prop) ->
      obj.propertyIsEnumerable prop

    notEnumerable = (obj, prop) ->
      !obj.propertyIsEnumerable prop

    enumerableAndNotEnumerable = () ->
      yes

    # 获取对象属性名，不要利用for ... in，因为这样不可枚举的属性无法抓取
    getPropertyName = (obj, iterateSelfBool, iteratePrototypeBool, includePropCb) ->
      props = [];
      while !!obj is yes
        if iterateSelfBool is yes
          for prop in Object.getOwnPropertyNames obj
            if props.indexOf prop is -1 and includePropCb obj, prop
              props.push prop
        if iteratePrototypeBool is no
          break
        iterateSelfBool = yes
        obj = Object.getPrototypeOf obj

      props

    # 设置节点 class
    setEleClass = (ele, cl) ->
      ele.setAttribute 'class', cl

    # 设置节点内容
    setEleContent = (ele, val) ->
      ele.innerHTML = val

    # 创建节点
    createEle = (na) ->
      doc.createElement na

    # 创建 li 节点并赋予内容
    createLiEle = (val, nor) ->
      li = createEle 'li'
      li.innerHTML = '<span class="glyphicon glyphicon-menu-right"></span>'
      cl = 'list-group-item '
      if !nor
          cl += 'text-danger '
          li.innerHTML = '<span class="glyphicon glyphicon-remove"></span>'

      setEleClass li, cl
      sp1 = createSpanEle ''
      sp2 = createSpanEle val
      #li.appendChild sp1
      #li.appendChild sp2

      li

    # 创建 option 节点并赋予内容
    createOptionEle = (val) ->
      option = createEle 'option'
      setEleContent option, val

    # 创建 span 节点并赋予内容
    createSpanEle = (val) ->
      span = createEle 'span'
      if val is ''
        setEleClass span, 'glyphicon glyphicon-menu-right'
      else
        setEleClass span, 'glyphicon glyphicon-remove'
        setEleContent span, val
        span

    # 数据处理
    render:  (msg, console) ->
      if msg is ''
        [yes, '']
      else
        # 判断是否为 console.log 语句
        # 其他 js 文件的 'console.log('xxx')' 语句将不会显示出来
        # 只显示 xxx
        if not console? then @append yes, msg
        try
          data = eval.call win, msg
          [yes, if isObejct data then data.toString() else data]
        catch error
          [no, error]

    # 对象处理
    handleObject: () ->

    append: (trueOrErr, value) ->
      li = createLiEle(value, trueOrErr)
      @ul.appendChild li
      @scrollBottom()

    # 清除所有内容
    clear: ->
      @ul.innerHTML = ''

    show: ->
      @isHide = no
      @container.setAttribute 'style', 'display: block'
      @

    hide: ->
      @isHide = yes
      @container.setAttribute 'style', 'display: none'
      @

    # 搜索当前 env 下符合 val 开头的属性
    searchAttribute: (val, env) ->
      array = []
      attrs = getPropertyName env, yes, yes, enumerableAndNotEnumerable()
      # console.log(attrs)
      for key in attrs
        if key.indexOf(val) is 0 then array.push key
      array

    appendInSelect: (array) ->
      all = ''
      for tmp in array
        all += '<option>' + tmp + '</option>'
      @select.innerHTML = all
      if array.length > 8 then size = 8 else size = array.length + 1
      @select.setAttribute 'size', size

    clearSelect: ->
      @select.innerHTML = ''

    # 侦听 input 变化
    inputListner: (e) ->
      val = @input.value
      pos = val.lastIndexOf('.')
      if pos is -1
        env = win
        # 输入后清空当前环境，之前把这个清空放在 input 回车事件里面，出现一个大坑
        # 我们输入完之后删除 input 的内容也会在不断监听变化
        # 因为字符串中存在字符'.'，导致又把 @env 设置了环境，导致清除失败
        @env = ''
      else
        tmp= val.substring 0, pos
        @env = tmp + '.'
        env = eval tmp
        # alert JSON.stringify env
      val = val.substring pos + 1, val.length
      @appendInSelect @searchAttribute val, env

    # 绑定window，捕捉js报错信息
    errListener: (error) ->
      # 只输出有用的错误信息
      msg = [
        "Error:"
        "filename: #{error.filename}"
        "lineno: #{error.lineno}"
        "message: #{error.message}"
        "type: #{error.type}"
      ]

    # 自动滚到至底部
    scrollBottom: ->
      @container.scrollTop = @container.scrollHeight

    constructor: ->
      # 是否初始化以及隐藏
      @isInit = no

      @msg = ''

      @body = getBody()

      @stack = new Stack()

      #  初始化
      @init()

      @isInit = yes

    init: ->
      @isHide = no
      #  输入语句当前环境, 默认 window
      @env = ''

      div = doc.createElement 'div'
      div.innerHTML = HTML

      @body.appendChild div

      @container = dom '#webug-container'
      @btn_clear = dom '#webug-clear'
      @btn_close = dom '#webug-close'
      @input = dom '#webug-input'
      @ul = dom '#webug-ul'
      @select = dom '#webug-select'

      # 绑定事件
      bind @btn_clear, CLICK, =>
        @clear()

      bind @input, KEYDOWN, (e) =>
        if e.keyCode is 13
          @msg = @input.value
          @stack.push @msg
          data = @render @msg
          @append data[0], data[1]
          @input.value = ''
        # up
        else if e.keyCode is 38
          #@input.value = @stack.up()
          @select.focus()
        # down
        else if e.keyCode is 40
          #@input.value = @stack.down()
          @select.focus()
        # right
        #else if e.keyCode is 39
          #@select.focus()

      # 监听 input 输入变化（暂时不兼容ie）
      bind @input, INPUT, (e) =>
        # console.log(@searchAttribute @input.value, win)
        @inputListner(e)

      bind @select, KEYDOWN, (e) =>
        if e.keyCode is 13
          #alert(@env)
          @input.value = @env + @select.value
          @input.focus()
          @clearSelect()
        else if e.keyCode is 37
          @input.focus()
          # 按键 keydown 下去就会跑到 input 上，按键起来时会触发到 input 的 keypress事件，所以阻止后续默认事件
          e.preventDefault()

      bind @select, CLICK, (e) =>
        @input.value = @select.value
        @input.focus()

      # 绑定 crtl + x 快捷键 (控制显示消失)
      bind @body, KEYDOWN, (e) =>
        if e.keyCode is 88 and e.ctrlKey
          if @isHide then @show() else @hide()


      # 绑定windown错误捕捉
      bind win, ERROR, (e) =>
        @errListener(e)

      # 劫持 console.log 方法
      # 生效条件为将 webug.js 放在要执行js语句前面
      win.console.log = (val) =>
        data = @render val, yes
        @append(data[0], data[1])
        UNDEFINED

      @isInit = yes
      @
) window, document
