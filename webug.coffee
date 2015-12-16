
# webug.js 0.0.1

((win, doc) ->

  "user strict"

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
    # 样式
    STYLE = '
          .webug-container {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 200px;
            font-color: #000;
            font-size: 16px;
            margin: 5px;
            padding: 5px;
            border-top: 3px solid #eeefee;
            overflow-y: scroll;
          }
          .webug-command {
              padding: 5px 0;
          }
          .webug-command::before {
              content: ">";
              color: rgb(53, 131, 252);
              font-weight: bold;
              display: inline-block;
              margin-right: 5px;
          }
          .webug-information {
              margin: 0;
              padding: 0;
          }
          .webug-echo {
              font-size: 16px;
              padding: 5px 0;
              border-bottom: 1px solid #eeefee;
              list-style: none;
          }
          .webug-echo::before {
              content: ">";
              color: rgb(133, 149, 173);
              font-weight: bold;
              display: inline-block;
              margin-right: 5px;
          }
          .webug-true {
              font-color: #066;
              border-bottom: 1px solid #eeefee;
              padding: 5px 12px;
              list-style: none;
          }
          .webug-error {
              color: #E81D20;
              border-bottom: 1px solid #eeefee;
              padding: 5px 12px;
              list-style: none;
          }
          .webug-error::before {
              content: "error: ";
          }
          .webug-edit {
              width: 80%;
              font-size: 16px;
              border: none;
              outline: none;
           }
          .webug-tips {
              position: fixed;
              right: 80px;
              bottom: 190px;
              border: 1px solid #000;
          }
          .webug-clear {
              position: fixed;
              bottom: 10px;
              right: 10px;
              padding: 2px 5px;
          }
      '

    # 模板HTML
    HTML = '
            <div id="webug-container" class="webug-container">
                <ul id="webug-content" class="webug-information">
                </ul>
                <div class="webug-command">
                    <input id="webug-input" class="webug-edit"/>
                </div>
                <select id="webug-select" class="webug-tips">
                </select>
                <button id="webug-btn-clear" class="webug-clear">Clear</button>
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
          if (obj.hasOwnProperty tmp) then attr.push tmp
        attr

    # 比较两个字符串，将后者字符串倒匹配，并添加到前者，重复字符串不添加
    # 如: resplaceString('xxx.abc', 'abcd') 返回 xxx.abcd
    resplaceString = (a, b) ->


    # 数据处理
    # 因为重载了 console.log 方法，假如有 console.log 语句会显示这句话出来
    render:  (msg, console) ->
      if msg is ''
        UNDEFINED
      else
        if not console? then @append 'echo', msg
        try
          data = eval.call win, msg
          [TRUE, JSON.stringify data]
        catch error
          [ERROR, error]

    # 对象处理
    handleObject: () ->

    append: (trueOrErr, value) ->
      li = doc.createElement 'li'
      li.setAttribute 'class', 'webug-' + trueOrErr
      li.innerHTML = value
      @content.appendChild li
      @scrollBottom()

    # 清除所有内容
    clear: ->
      @content.innerHTML = ''

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
      attrs = getAttrs(env)
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

    # 侦听 input 变化
    inputListner: (e) ->
      val = @input.value
      pos = val.lastIndexOf('.')
      if pos is -1
        env = win
      else
        @env = val.substring 0, pos
        env = eval @env
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
      @isInit = @isHide = no

      @msg = ''

      @body = getBody()

      @stack = new Stack()

      #  输入语句当前环境, 默认 window
      @env = ''
      #  初始化
      @init()

    init: ->
      css = doc.createElement 'style'
      css.innerHTML = STYLE

      div = doc.createElement 'div'
      div.innerHTML = HTML

      @body.appendChild css
      @body.appendChild div

      @btn = dom "#webug-btn-clear"
      @input = dom "#webug-input"
      @content = dom '#webug-content'
      @container = dom '#webug-container'
      @select = dom '#webug-select'

      # 绑定事件
      bind @btn, CLICK, =>
        @clear()

      bind @input, KEYDOWN, (e) =>
        if e.keyCode is 13
          @msg = @input.value
          @stack.push @msg
          data = @render @msg
          @append data[0], data[1]
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
          @input.value = @env + '.' + @select.value
          @input.focus()
        else if e.keyCode is 37
          @input.focus()
          # 按键 keydown 下去就会跑到 input 上，按键起来时会触发到 input 的 keypress事件，所以阻止后续默认事件
          e.preventDefault()
          #console.log @input.selectionStart
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
      win.console.log = (val) =>
        data = @render val, yes
        @append(data[0], data[1])
        UNDEFINED

      @isInit = yes
      @

  webug = new Webug()
) window, document
