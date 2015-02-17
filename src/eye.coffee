_ = require 'lodash'
Buffer = require './buffer'
Indicator = require './indicator'
Interface = require './interface'
utilities = require './utilities'
connection = require './connection'

module.exports = class Eye

  constructor: ->

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

    @indicator = new Indicator size: 60, visible: false

    @frozen = false

    @enabled = true

    @connection = new Connection()

    window.addEventListener 'focus', -> windowActive = true
    window.addEventListener 'blur',  -> windowActive = false

    @connection.connect()


  triggerEvent: (event) ->
    event = event.split /\s+/
    if event.length == 1
      event = event[0]
      evt = new CustomEvent event, bubbles: true, clientX: 0, clientY: 0
      for el in gazeEls
        if el isnt null then el.dispatchEvent(evt)
    else
      for e in event
        @triggerEvent e


  handleWink: (side, el) ->
    switch side
      when 'left'
        if ++leftCount <= 3 then return
        leftCount = 0
        @triggerEvent 'leftwink wink'
      when 'right'
        if ++rightCount <= 3 then return
        rightCount = 0
        @triggerEvent 'rightwink wink'


  handleBlink: (open, close) ->
    blinkTime = 600
    cushion = 200

    # if the last open isn't recent, then skip.
    if _.now() - open > 100 then return

    diff = open - close

    if ((diff >= blinkTime - cushion) && (diff <= blinkTime + cushion))
      @indicator.scale(0.8, 200)
      @freeze()
      @triggerEvent 'blink mousedown mouseup click'


  handleDoubleBlink: (open, close) ->
    diff = close - open
    if _.now() - close > 500 then return
    if (diff < 200)
      @indicator.scale(0.8, 200)
      @freeze()
      @triggerEvent 'doubleblink mousedown mouseup click'


  handleBlinks = (frame) ->
    open  = @opens.get 0
    close = @closes.get 0
    dOpen = @opens.get 1
    left  = frame.lefteye.avg
    right = frame.righteye.avg

    if (open  && close) then @handleBlink open, close
    if (dOpen && close) then @handleDoubleBlink dOpen, close

    if ((left.x == 0 && left.y == 0) && (right.x != 0 && right.y != 0))
      @handleWink 'left'

    if ((left.x != 0 && left.y != 0) && (right.x == 0 && right.y == 0))
      @handleWink 'right'


  # Handles gaze event. If the current gaze element is unchanged, then
  # do nothing... but if it has changed, trigger a gazeleave on previous and
  # a gaze on the new one.
  handleGaze = ->
    els = @indicator.getGazeElements() or []
    for el in @gazeEls
      if el not in els
        @triggerEvent 'gazeleave mouseleave mouseout'
    @gazeEls = els
    @triggerEvent 'gaze mousemove mouseenter mouseover'

  freeze: ->
    @frozen = true
    setTimeout =>
      @frozen = false
    , 200

  enable: ->
    @indicator.show()
    @enabled = true

  disable: ->
    @triggerEvent 'gazeleave'
    @gazeEls = []
    @indicator.hide()
    @enabled = false

  calcScreenOffsets: ->
    # compute width of borders
    borderWidth = (window.outerWidth - window.innerWidth) / 2

    # compute absolute page position
    innerScreenX = window.screenX + borderWidth
    innerScreenY = (window.outerHeight - window.innerHeight - borderWidth) +
      window.screenY

    @innerScreenX = innerScreenX
    @innerScreenY = innerScreenY


  handleFrame: (frame) ->
    if window.Eye.frozen or !Eye.enabled or !windowActive then return

    if @lastFrame

      closedThisFrame = frame.avg.x == 0 and frame.avg.y == 0
      openLastFrame   = @lastFrame.avg.x != 0 and @lastFrame.avg.y != 0

      closedLastFrame = @lastFrame.avg.x == 0 and @lastFrame.avg.y == 0
      openThisFrame   = frame.avg.x != 0 and frame.avg.y != 0

      if closedThisFrame and openLastFrame
        closes.push(new Date());

      if closedLastFrame and openThisFrame
        opens.push(new Date());

    @lastFrame = frame

    if frame.avg.x != 0 and frame.avg.y != 0
      @calcScreenOffsets()

      # Correct for window offsets.
      frame.avg.x -= Eye.innerScreenX
      frame.avg.y -= Eye.innerScreenY

      @indicator.move frame.avg.x, frame.avg.y

      @handleGaze()
      @handleBlinks(frame)

  calibrate: ->
    maxPointCount = 16
    pointCount = 0

    @connection.send 'calibration:start', maxPointCount

    indicator = @indicator
    transition = 'all 0.5s'
    transform = 'translate3d(-5px, -5px, 0)'

    @calcScreenOffsets()

    @indicator.hide()

    points = _.shuffle [
      [0.1, 0.1], [0.4, 0.1], [0.6, 0.1], [0.9, 0.1]
      [0.1, 0.4], [0.4, 0.4], [0.6, 0.4], [0.9, 0.4]
      [0.1, 0.6], [0.4, 0.6], [0.6, 0.6], [0.9, 0.6]
      [0.1, 0.9], [0.4, 0.9], [0.6, 0.9], [0.9, 0.9]
    ]

    curtain = utilities.makeElement 'div',
      zIndex: 100000
      position: 'fixed'
      height: '100%'
      width: '100%'
      left: 0
      top: 0
      backgroundColor: 'transparent'
      transition:       transition
      MozTransition:    transition
      WebkitTransition: transition
      msTransition:     transition

    point = utilities.makeElement 'div',
      zIndex: 100001
      position: 'fixed'
      height: '10px'
      width: '10px'
      borderRadius: '999px'
      backgroundColor: 'white'
      left: 0
      top: 0
      transform:        transform
      MozTransform:     transform
      WebkitTransform:  transform
      msTransform:      transform

    document.body.appendChild curtain
    document.body.appendChild point

    setTimeout ->
      curtain.style.backgroundColor = 'rgba(0,0,0,0.8)'
    , 100

    nextPoint = ->
      x = parseInt((window.innerWidth) * points[pointCount][0])
      y = parseInt((window.innerHeight) * points[pointCount][1])

      point.style.left = x + 'px'
      point.style.top = y + 'px'
      Eye.connection.send 'calibration:pointstart',
        x: x + Eye.innerScreenX
        y: y + Eye.innerScreenY

      setTimeout ->
        Eye.connection.send 'calibration:pointend'
        pointCount++
        if pointCount < maxPointCount
          nextPoint()
        else
          curtain.style.backgroundColor = 'transparent'
          setTimeout ->
            indicator.show()
            document.body.removeChild curtain
            document.body.removeChild point
          , 500
      , 2000

    nextPoint()
