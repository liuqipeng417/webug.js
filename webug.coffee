
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
                <button id="webug-btn-clear" class="webug-clear">Clear</button>
            </div>
     '

    UNDEFINED = undefined

    dom = (ele) ->
      doc.querySelector ele

    # 绑定事件
    bind = (ele, event, callback) ->
      ele.addEventListener event, callback, no

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

    # 数据处理
    # 因为重载了 console.log 方法，假如有 console.log 语句会显示这句话出来
    render =  (msg, console) ->
      if msg is ''
        UNDEFINED
      #else if isNumber msg
      #  append 'true', msg
      else
        if not console? then append 'echo', msg
        try
          ['true', eval.call window, msg]
        catch error
          ['error', error]


    append = (trueOrErr, value) ->
      li = doc.createElement 'li'
      li.setAttribute 'class', 'webug-' + trueOrErr
      li.innerHTML = value
      dom("#webug-content").appendChild li

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

    constructor: ->
      # 是否初始化以及隐藏
      @isInit = @isHide = no
      @msg = ''
      @body = getBody()
      @stack = new Stack()
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

      # 绑定事件
      bind @btn, 'click', =>
        @clear()

      bind @input, 'keydown', (e) =>
        if e.keyCode is 13
          @msg = @input.value
          @stack.push @msg
          data = render @msg
          append data[0], data[1]
        else if e.keyCode is 38
          @input.value = @stack.up()
        else if e.keyCode is 40
          @input.value = @stack.down()

      # 绑定 crtl + x 快捷键
      bind @body, 'keydown', (e) =>
        if e.keyCode is 88 and e.ctrlKey
          if @isHide then @show() else @hide()

      # 绑定windown错误捕捉
      bind win, 'error', (e) =>
        @errListener(e)


      # 劫持 console.log 方法
      win.console.log = (val) ->
        data = render val, yes
        append(data[0], data[1])
        return



      @isInit = yes
      @

  webug = new Webug()
) window, document
