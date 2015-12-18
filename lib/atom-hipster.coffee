AtomHipsterView = require './atom-hipster-view'
{CompositeDisposable} = require 'atom'

qs = (selector) -> document.querySelector selector

module.exports = AtomHipster =
  atomHipsterView: null
  modalPanel: null
  subscriptions: null
  elements: {}
  boxes: []

  activate: (state) ->
    @atomHipsterView = new AtomHipsterView(state.atomHipsterViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomHipsterView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-hipster:toggle': => @toggle()

    setTimeout (=>
      @init()
      @magic()
    ), 1000

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomHipsterView.destroy()

  serialize: ->
    atomHipsterViewState: @atomHipsterView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  init_image: ->
    @elements.image = document.createElement 'img'
    @elements.image.id='editor-background-image'
    @elements.image.setAttribute 'src', "/Users/eugene/Downloads/pexels-photo.jpg"
    @elements.main.appendChild(@elements.image);

  init: ->
    @elements.workspace = qs 'atom-workspace'
    @elements.tab_bar = qs '.tab-bar'

    @elements.main = document.createElement 'div'
    @elements.main.id = 'hipster-main'
    @elements.main.style.cssText += "
      position: absolute;
      top: 0px;
      left: 0px;
      width: 100%;
      height: 100%;
      background: url(/Users/eugene/Downloads/pexels-photo.jpg);
      background-size: cover;
      z-index: 1;"


    @elements.workspace.insertBefore @elements.main, @elements.workspace.firstChild
    @elements.tab_bar.style.cssText += "z-index: 2;"

    style = document.createElement 'style'
    style.type = "text/css"
    style.innerHTML = "
      .item-views {
        background:rgba(0,0,0,0.8)!important;
        z-index: 2;
      }

      atom-panel {
        z-index: 2;
      }

      atom-text-editor {
        background: transparent;
      }

      atom-text-editor::shadow .gutter {
        background-color: rgba(0,0,0,.2);
      }
    "
    @elements.main.appendChild style

  magic: ->
    canvas = @elements.canvas = document.createElement 'canvas'
    canvas.width = @elements.main.clientWidth;
    canvas.height = @elements.main.clientHeight;
    canvas.style.backgroundColor = "#000"
    @elements.main.appendChild(canvas)

    @ctx = @elements.canvas.getContext("2d")

    background = new Image
    background.src = "/Users/eugene/Downloads/pexels-photo.jpg"

    background.onload = =>
      @ctx.drawImage background, 0, 0

    @boxes.push(new Box(canvas, @ctx)) for [0...15]

    @tick()

  tick: ->
    @ctx.clearRect(0, 0, @elements.canvas.width, @elements.canvas.height);
    box.draw() for box in @boxes
    requestAnimationFrame => @tick()

class Box
  constructor: (canvas, ctx) ->
    @canvas = canvas
    @ctx = ctx
    @x = Math.random() * @canvas.width;
    @y = Math.random() * @canvas.height;
    @width = @height = Math.random() * 10;
    @vx = (~(Math.random() * 2 | 0) + 1 | 1) * 0.1 * @width;
    @vy = (~(Math.random() * 2 | 0) + 1 | 1) * 0.1 * @width;
    @color = "#fff";

  draw: ->
    @x += @vx * 10
    @y += @vy * 10

    if @x > @canvas.width or @x < 0
      @vx = @vx * -1
    if @y > @canvas.height or @y < 0
      @vy = @vy * -1

    @ctx.beginPath()
    @ctx.arc(@x | 0, @y | 0, @width, 0, 2 * Math.PI, false)
    @ctx.fillStyle = @color
    @ctx.fill()
