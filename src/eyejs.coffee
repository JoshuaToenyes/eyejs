##
# Defines

_           = require 'lodash'
Buffer      = require './Buffer'
SmoothingBuffer = require './SmoothingBuffer'
Indicator   = require './Indicator'
Connection  = require './Connection'
EventEmitter = (require 'events').EventEmitter

S_ALPHA = 0.2

S_WINDOW = 20

S_MIN = 1.2

##
# The EyeJS class.
#
# @class EyeJS

module.exports = class EyeJS extends EventEmitter

  constructor: (opts = {}) ->

    @smoothedX = new SmoothingBuffer(S_WINDOW, S_ALPHA, S_MIN)

    @smoothedY = new SmoothingBuffer(S_WINDOW, S_ALPHA, S_MIN)

    # List of previous eye-opens.
    @opens = new Buffer()

    # List of previous eye-closes.
    @closes = new Buffer()

    # The last frame received.
    @lastFrame = null

    # Element currently gazing-at.
    @gazeEls = []

    # Number of frames the left-eye has been closed for.
    @leftCount = 0

    # Number of frames the right-eye has been closed for.
    @rightCount = 0

    @windowActive = true

    @indicator = new Indicator size: 60, visible: true

    @frozen = false

    @enabled = true

    @connection = new Connection()

    window.addEventListener 'pageshow', => @windowActive = true

    window.addEventListener 'pagehide', => @windowActive = false

    @connection.on 'gaze', (e) => @handleFrame(e)

    @connection.connect()


  triggerEvents: (event) ->
    event = event.split /\s+/
    if event.length == 1
      event = event[0]
      evt = new CustomEvent event, bubbles: true, clientX: 0, clientY: 0
      for el in @gazeEls
        if el isnt null then el.dispatchEvent(evt)
    else
      for e in event
        @triggerEvents e


  handleWink: (side, el) ->
    switch side
      when 'left'
        if ++leftCount <= 3 then return
        leftCount = 0
        @triggerEvents 'leftwink wink'
      when 'right'
        if ++rightCount <= 3 then return
        rightCount = 0
        @triggerEvents 'rightwink wink'


  handleBlink: (open, close) ->
    blinkTime = 600
    cushion = 200

    # if the last open isn't recent, then skip.
    if _.now() - open > 100 then return

    diff = open - close

    if ((diff >= blinkTime - cushion) && (diff <= blinkTime + cushion))
      @indicator.scale(0.8, 200)
      @freeze()
      @triggerEvents 'blink mousedown mouseup click'


  handleDoubleBlink: (open, close) ->
    diff = close - open
    if _.now() - close > 500 then return
    if (diff < 200)
      @indicator.scale(0.8, 200)
      @freeze()
      @triggerEvents 'doubleblink mousedown mouseup click'


  handleBlinks: (frame) ->
    open  = @opens.get 0
    close = @closes.get 0
    dOpen = @opens.get 1
    left  = frame.left.avg
    right = frame.right.avg

    if (open  && close) then @handleBlink open, close
    if (dOpen && close) then @handleDoubleBlink dOpen, close

    # if ((left.x == 0 && left.y == 0) && (right.x != 0 && right.y != 0))
    #   @handleWink 'left'
    #
    # if ((left.x != 0 && left.y != 0) && (right.x == 0 && right.y == 0))
    #   @handleWink 'right'


  # Handles gaze event. If the current gaze element is unchanged, then
  # do nothing... but if it has changed, trigger a gazeleave on previous and
  # a gaze on the new one.
  handleGaze: ->
    el = @indicator.getGazeElement()

    if el is null then return

    el.setAttribute 'eyejs-gaze', ''

    for ge in @gazeEls
      if ge and ge isnt el
        ge.removeAttribute 'eyejs-gaze'
        @triggerEvents 'gazeleave mouseleave mouseout'

    @gazeEls = [el]
    @triggerEvents 'gaze mousemove mouseenter mouseover'

  freeze: ->
    @frozen = true
    setTimeout =>
      @frozen = false
    , 200

  enable: ->
    @indicator.show()
    @enabled = true

  disable: ->
    @triggerEvents 'gazeleave'
    @gazeEls = []
    @indicator.hide()
    @enabled = false

  ##
  # Calculates the positional offsets of the browser window relative to the
  # screen.
  #
  # @todo This should use a click event, or perhaps be delegated to the clients.
  calcScreenOffsets: ->
    # compute width of borders
    borderWidth = (window.outerWidth - window.innerWidth) / 2

    # compute absolute page position
    innerScreenX = window.screenX + borderWidth
    innerScreenY = (window.outerHeight - window.innerHeight - borderWidth) +
      window.screenY

    @innerScreenX = innerScreenX
    @innerScreenY = innerScreenY


  ##
  # @todo This method should use the timestamp on the frame, not a new Date
  # object when pushing opens and closes.
  handleFrame: (frame) ->
    if @frozen or !@enabled or !@windowActive then return

    if @lastFrame

      closedThisFrame = frame.avg.x == 0 and frame.avg.y == 0
      openLastFrame   = @lastFrame.avg.x != 0 and @lastFrame.avg.y != 0

      closedLastFrame = @lastFrame.avg.x == 0 and @lastFrame.avg.y == 0
      openThisFrame   = frame.avg.x != 0 and frame.avg.y != 0

      if closedThisFrame and openLastFrame
        @closes.push(new Date());

      if closedLastFrame and openThisFrame
        @opens.push(new Date());

    @lastFrame = frame

    if frame.avg.x != 0 and frame.avg.y != 0
      @calcScreenOffsets()

      frame.avg.x /= window.devicePixelRatio
      frame.avg.y /= window.devicePixelRatio

      # Correct for window offsets.
      frame.avg.x -= @innerScreenX
      frame.avg.y -= @innerScreenY

      @smoothedX.push frame.avg.x
      @smoothedY.push frame.avg.y

      e =
        rawx: frame.avg.x
        rawy: frame.avg.y
        x:    @smoothedX.top()
        y:    @smoothedY.top()

      @emit 'gaze', e

      @indicator.move @smoothedX.top(), @smoothedY.top()

      @handleGaze()
      @handleBlinks(frame)
