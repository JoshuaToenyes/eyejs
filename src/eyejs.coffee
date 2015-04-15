##
# Defines

_           = require 'lodash'
Buffer      = require './Buffer'
SmoothingBuffer = require './SmoothingBuffer'
Indicator   = require './Indicator'
Connection  = require './Connection'
EventEmitter = (require 'events').EventEmitter
BlinkController = require './BlinkController'

S_ALPHA = 0.08

S_WINDOW = 20

S_MIN = 1.2

##
# The amount of time to wait until we assume the user has closed thier eyes
# or is no-longer looking at the screen.
#
# @const FRAME_TIMEOUT

FRAME_TIMEOUT = 400


##
# The amount of time until we trigger a fixation on an element.
#
# @const FIXATION_TIME

FIXATION_TIME = 180


##
# The EyeJS class.
#
# @class EyeJS

module.exports = class EyeJS extends EventEmitter

  constructor: (opts = {}) ->

    @smoothedX = new SmoothingBuffer(S_WINDOW, S_ALPHA, S_MIN)

    @smoothedY = new SmoothingBuffer(S_WINDOW, S_ALPHA, S_MIN)

    @blinks = new BlinkController

    @blinkEl = null

    @blinks.on 'open', (timeClosed) =>
      @triggerEvents 'eyesopen'
      if timeClosed > 400 and timeClosed < 2000
        @emit 'blink', @fixatedEl
        @triggerEvents 'blink click'
      @_preventElChange = false

    @blinks.on 'close', =>
      @_preventElChange = true
      @triggerEvents 'eyesclose'

    # The last frame received.
    @lastFrame = null

    # Element currently gazing-at.
    @gazeEl = null

    # Element currently fixated-on.
    @fixatedEl = null

    # Timer to track fixations.
    @fixationTimer = null

    @windowActive = true

    @indicator = new Indicator size: 60, visible: true

    @frozen = false

    @_preventElChange = false

    @enabled = true

    @connection = new Connection()

    window.addEventListener 'pageshow', => @windowActive = true

    window.addEventListener 'pagehide', => @windowActive = false

    @connection.on 'gaze', (e) => @handleFrame(e)

    @connection.connect()

    @frameWatcher = setInterval =>
      if not @lastFrame then return
      if _.now() - @lastFrame.timestamp > FRAME_TIMEOUT
        @blinks.pushClose()
    , 100


  triggerGazeEvents: (event) ->
    @_triggerEvents(event, @gazeEl)


  triggerEvents: (event) ->
    @_triggerEvents(event, @fixatedEl)




  ##
  # This method triggers space-separated event names on the current gaze
  # element.
  #
  # @method triggerEvents
  # @public

  _triggerEvents: (event, el) ->
    event = event.split /\s+/
    if el?.tagName is 'INPUT'
      el.focus()
      return
    if event.length == 1
      event = event[0]
      evt = new CustomEvent event, bubbles: true, clientX: 0, clientY: 0
      if el isnt null then el.dispatchEvent(evt)
    else
      for e in event
        @triggerEvents e



  _resetFixationTimer: ->
    clearTimeout @fixationTimer
    @fixationTimer = setTimeout =>
      @fixatedEl = @gazeEl
      if @fixatedEl is null then return
      @fixatedEl.setAttribute 'data-eyejs-fixated', ''
      @triggerEvents 'fixation'
      @emit 'fixation', @fixatedEl
    , FIXATION_TIME


  ##
  # Handles gaze event. If the current gaze element is unchanged, then
  # do nothing... but if it has changed, trigger a gazeleave on previous and
  # a gaze on the new one.
  #
  # This method is only called if there are useful coordinates to work with.
  # So for instance, the frame handler will only call this function if there
  # are non-zero coordinates. Therefore, it won't get called if the eyes are
  # closed or otherwise off screen.

  handleGaze: ->
    if @_preventElChange then return

    # Get the element currently under the gaze indicator.
    el = @indicator.getGazeElement()

    # If there is an element... (there may not be if the user isn't looking
    # inside the browser window).
    if el
      el.setAttribute 'data-eyejs-gaze', ''

      if @gazeEl and @gazeEl isnt el
        @gazeEl.removeAttribute 'data-eyejs-gaze'
        @triggerGazeEvents 'gazeleave mouseleave mouseout'

      if @fixatedEl and @fixatedEl isnt el
        @fixatedEl.removeAttribute 'data-eyejs-fixated'
        @triggerEvents 'fixationend'
        @emit 'fixationend', @fixatedEl
        @fixatedEl = null

      if @gazeEl isnt el and @fixatedEl is null
        @_resetFixationTimer()

      @gazeEl = el
      @triggerGazeEvents 'gaze mouseenter mouseover'

    else
      @gazeEl = null


  ##
  #

  freeze: ->
    @frozen = true
    setTimeout =>
      @frozen = false
    , 200


  ##
  # Enables EyeJS and shows the indicator.
  #
  # @method enable
  # @public

  enable: ->
    @indicator.show()
    @enabled = true


  ##
  # Disables the EyeJS, hides the indicator, and triggers a `gazeleave` event
  # on any active gaze elements.
  #
  # @method disable
  # @public


  disable: ->
    @triggerEvents 'gazeleave'
    @gazeEl = null
    @indicator.hide()
    @enabled = false


  ##
  # Calculates the positional offsets of the browser window relative to the
  # screen. This method will currently return the incorrect result if something
  # is open on the bottom of the window, such as the developer tools.
  #
  # @todo This should use a click event, or perhaps be delegated to the clients.
  #
  # @method _calcScreenOffsets
  # @private

  _calcScreenOffsets: ->
    # compute width of borders
    borderWidth = (window.outerWidth - window.innerWidth) / 2

    # compute absolute page position
    @innerScreenX = window.screenX + borderWidth
    @innerScreenY = (window.outerHeight - window.innerHeight - borderWidth) +
      window.screenY


  ##
  # This method handles frames as they are delivered over the websocket
  # connection. A frame is a single measurement set of gaze position and eye
  # availability. Eye movement is transmitted from the eye tracker to this
  # method, via the websocket.
  #
  # @param {Frame} frame - The EyeJS frame to process.
  #
  # @method handleFrame
  # @public

  handleFrame: (frame) ->
    if @frozen or !@enabled or !@windowActive then return

    if not frame.available.both then @blinks.pushClose()
    if frame.available.both then @blinks.pushOpen()

    @lastFrame = frame

    # Only handle frames that have gaze position information.
    if frame.avg.x != 0 and frame.avg.y != 0

      # Calculate the window offset.
      @_calcScreenOffsets()

      # Correct for different pixel densities.
      frame.avg.x /= window.devicePixelRatio
      frame.avg.y /= window.devicePixelRatio

      # Correct for window offsets.
      frame.avg.x -= @innerScreenX
      frame.avg.y -= @innerScreenY

      # Smooth the positions.
      @smoothedX.push frame.avg.x
      @smoothedY.push frame.avg.y

      # Emit the raw frame, if anyone cares.
      @emit 'raw', frame

      # Move the indicator to the new position.
      @indicator.move @smoothedX.top(), @smoothedY.top()

      # Handle the actual gaze.
      @handleGaze()

      # Build and emit the gaze event.
      e =
        rawx: frame.avg.x
        rawy: frame.avg.y
        x:    @smoothedX.top()
        y:    @smoothedY.top()
        el:   @gazeEl
      @emit 'gaze', e
