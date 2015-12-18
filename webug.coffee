((win, doc) ->
  "user strict"

  # 同步加载相关资源
  (() ->
    css = doc.createElement 'link'
    jq = doc.createElement 'script'
    bt = doc.createElement 'script'
    css.setAttribute 'rel', 'styleSheet'
    css.setAttribute 'href', 'bootstrap/css/bootstrap.min.css'
    jq.src = 'jquery.min.js'
    jq.onload = jq.readyreadystatechange = () ->
      if !jq.readyState || /loaded|complete/.test jq.readyState
        console.log 'jq ok'
        doc.body.appendChild(bt)
    bt.src = 'bootstrap/js/bootstrap.min.js'
    bt.onload = bt.readyreadystatechange = () ->
      if !bt.readyState || /loaded|complete/.test bt.readyState
        console.log 'load ok'
        bt.onload = bt.readystatechange = null

        webug = new Webug
    doc.body.appendChild css
    doc.body.appendChild jq)()


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
        @data[@index--]
      else
        @data[@index]

    down: () ->
      if @index isnt (@data.length - 1)
        @data[@index++]
      else
        @data[@index]

  class Webug
    # 模板HTML
    HTML = '
          <div id="webug-up" class="progress" style="margin:0;height:8px">
            <div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="60" aria-valuemin="0" aria-valuemax="100" style="width: 100%;">
            </div>
          </div>
          <div id="webug-container" class="panel panel-default" style="padding-top:5px;margin:0;">
            <div class="btn-group pull-right" role="group" aria-label="...">
              <button id="webug-clear" type="button" class="btn btn-info btn-sm">
                <span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>
              </button>
              <button id="webug-close" type="button" class="btn btn-danger btn-sm">
                <span class="glyphicon glyphicon-remove-sign" aria-hidden="true"></span></button>
              </button>
            </div>
            <ul id="webug-ul" class="list-group" style="height:150px;overflow-y:scroll;margin: 40px 0 10px"></ul>
            <div class="input-group input-group-bg">
              <span class="input-group-addon ">></span>
              <input id="webug-input" type="text" class="form-control" placeholder="" aria-describedby="sizing-addon3">
            </div>
            <select id="webug-select" class="form-control" size="" style="width:200px;position:fixed;bottom:40px;left:50px;display:none"></select>
          </div>
     '

    UNDEFINED = undefined
    CLICK = 'click '
    KEYDOWN = 'keydown '
    TRUE = 'true '
    ERROR = 'error '
    INPUT = 'input '
    CHANGE = 'change '
    MOUSEUP = 'mouseup '
    MOUSEDOWN = 'mousedown '
    MOUSEMOVE = 'mousemove '

    # 绑定事件
    bind = (ele, event, callback) ->
      $(ele).on event, (e) ->
        callback(e);
    # e.preventDefault()


    # 解除绑定事件
    unbind = (ele, event, callback) ->
      #ele.on event, callback

    isNull = (val) -> val is null

    isArray = Array.isArray

    isNumber = (val) ->
      !isNaN(val)

    isObejct = (val) ->
      typeof val is 'object' and not isFunction(val) and not isNull(val)

    isFunction = (val) ->
      typeof val is 'function'

    getBody = -> $ 'body'

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

    # 创建 li 节点并赋予内容
    createLiEle = (val, nor) ->
      li = $ '<li style="padding:5px 15px"></li>'
      sp = '<span class="glyphicon glyphicon-menu-right"></span><span style="margin-left:16px">'
      cl = 'list-group-item '
      if nor is no
        cl += 'text-danger '
        sp = '<span class="glyphicon glyphicon-remove"></span><span style="margin-left:16px">'
      else if nor is 'result'
        sp = '<span style="margin-left:30px"></span><span>'
      sp += val + '</span>'
      li.html sp
      li.addClass cl
      li

    # 数据处理
    render: (msg, console) ->
      if msg is ''
        [yes, '']
      else
        # 判断是否为 console.log 语句
        # 其他 js 文件的 'console.log('xxx')' 语句将不会显示出来
        # 只显示 xxx
        if not console? then @append yes, msg
        try
          data = eval.call win, msg
          ['result',
            if isObejct data
              JSON.stringify data
            else if isFunction data
              if !!data.toString
                data.toString()
              else if !!data.valueOf
                data.valueOf()
            else
              data
          ]
        catch error
          [no, error]

    append: (trueOrErr, value) ->
      if value isnt ''
        li = createLiEle(value, trueOrErr)
        @ul.append li
        @scrollBottom()

    # 清除所有内容
    clear: ->
      @ul.empty()

    show: ->
      @isHide = no
      @container.show()

    hide: ->
      @isHide = yes
      @container.hide()

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
      @select.html all
      if array.length > 8 then size = 8 else size = array.length + 1
      @select.attr 'size', size
      @controlSelectPos()
      if size is 1 then @select.hide() else @select.show()

    clearSelect: ->
      @select.html ''
      @select.hide()

    clearInput: ->
      @input.val ''

    controlSelectPos: ->
      @select.css 'left', (@input.val().length * 5 + 50) + 'px'

    # 侦听 input 变化
    inputListner: (e) ->
      val = @input.val()
      if val.length is 0
        @select.hide()
      else
        pos = val.lastIndexOf('.')
        if pos is -1
          env = win
          # 输入后清空当前环境，之前把这个清空放在 input 回车事件里面，出现一个大坑
          # 我们输入完之后删除 input 的内容也会在不断监听变化
          # 因为字符串中存在字符'.'，导致又把 @env 设置了环境，导致清除失败
          @env = ''
        else
          tmp = val.substring 0, pos
          @env = tmp + '.'
          env = eval tmp
        # alert JSON.stringify env
        val = val.substring pos + 1, val.length
        @appendInSelect @searchAttribute val, env

    ### 绑定window，捕捉js报错信息
    errListener: (error) ->
      # 只输出有用的错误信息
      msg = [
        "Error:"
        "filename: #{error.filename}"
        "lineno: #{error.lineno}"
        "message: #{error.message}"
        "type: #{error.type}"
      ]

    ###

    # 自动滚到至底部
    scrollBottom: ->
      @ul.scrollTop @ul.prop 'scrollHeight'

    selectPos: ->
      @select
    constructor: ->
    # 是否初始化以及隐藏
      @isInit = no
      @isHide = no
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

      div = $ '<div style="position:fixed;bottom:0;left:0;"></div>'
      div.html HTML

      @body.append div

      @container = $ '#webug-container'
      @btn_clear = $ '#webug-clear'
      @btn_close = $ '#webug-close'
      @input = $ '#webug-input'
      @ul = $ '#webug-ul'
      @select = $ '#webug-select'
      @div_up = $ '#webug-up'

      # console.log @ul
      # console.log @btn_clear
      # 绑定事件

      # 拖拽
      @is_Mouse_Down = no
      bind @div_up, MOUSEDOWN, (e) =>
        @src_pos_y = e.pageY;
        #console.log @src_pos_y
        @is_Mouse_Down = yes

      bind doc, CLICK + MOUSEUP, (e) =>
        if @is_Mouse_Down is yes
          @is_Mouse_Down = no
          #console.log ok

      bind doc, MOUSEMOVE, (e) =>
        if @is_Mouse_Down is yes
          @dest_pos_y = e.pageY
          move_Y = @src_pos_y - @dest_pos_y
          #console.log @ul.height() + move_Y
          @src_pos_y = @dest_pos_y
          @ul.height @ul.height() + move_Y

      # 按钮
      bind @btn_clear, CLICK, =>
        @clear()

      bind @btn_close, CLICK, =>
        @hide()

      # 输入框
      bind @input, KEYDOWN, (e) =>
        if e.keyCode is 13
          @msg = @input.val()
          @stack.push @msg
          data = @render @msg
          @append data[0], data[1]
          @clearInput()
          @clearSelect()
        # up
        else if e.keyCode is 38
          #@input.value = @stack.up()
          if @select.is ':hidden'
            @input.val @stack.up()
            @input.prop 'selectionStart', @input.val().length
            e.preventDefault()
          else
            @select.focus()
        # down
        else if e.keyCode is 40
          #@input.value = @stack.down()
          if @select.is ':hidden'
            @input.val @stack.down()
            @input.prop 'selectionStart', @input.val().length
            e.preventDefault()
          else
            @select.focus()
          # right
          #else if e.keyCode is 39
          #@select.focus()

      bind @input, INPUT, (e) =>
        # console.log(@searchAttribute @input.value, win)
        @inputListner(e)

      # 提示框
      bind @select, KEYDOWN, (e) =>
        if e.keyCode is 13
          #alert(@env)
          @input.val @env + @select.val()
          @input.focus()
          @clearSelect()
        else if e.keyCode is 37
          @input.focus()
          # 按键 keydown 下去就会跑到 input 上，按键起来时会触发到 input 的 keypress事件，所以阻止后续默认事件
          e.preventDefault()

      bind @select, CLICK, (e) =>
        @input.val @select.val()
        @input.focus()

      # 绑定 crtl + x 快捷键 (控制显示消失)
      bind @body, KEYDOWN, (e) =>
        if e.keyCode is 88 and e.ctrlKey
          if @isHide then @show() else @hide()

      # 绑定windown错误捕捉
      # bind win, ERROR, (e) =>
      #  @errListener(e)

      # 劫持 console.log 方法
      # 生效条件为将 webug.js 放在要执行js语句前面
      win.console.log = (val) =>
        data = @render val, yes
        @append(data[0], data[1])
        UNDEFINED
      
    @
) window, document
