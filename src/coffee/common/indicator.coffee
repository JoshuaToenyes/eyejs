_ = require 'lodash'



##
# Gaze indicator class represents the gaze-indicator object dynamically
# rendered on the screen.
#
module.exports = class Indicator

  ##
  # Creates the gaze indicator object take a variety of options affecting how
  # it is rendered and it's behavior.
  #
  # @constructor
  #
  # @param {Object} [opts] Optional indicator options.
  #
  # @param {string} [opts.transform] Initial transformation.
  #
  # @param {string} [opts.transition] Transition setting.
  #
  # @param {boolean} [opts.visible] Visibility setting. If set to false, then
  # the indicator is initially invisible.
  #

  constructor: (opts = {}) ->

    transform  = opts.transform  or 'translate3d(0, 0, 0)'
    transition = opts.transition or '-webkit-transform 0.2s ease-out'

    if opts.visible?
      visibility = opts.visible ? 'visible' : 'hidden'
    else
      visibility = 'visible'

    @transforms = {}
    @size = +opts.size or 40
    @scaleTimer = null

    @el = document.createElement('div')
    styles =
      position:         'fixed'
      height:           @size + 'px'
      width:            @size + 'px'
      top:              0
      left:             0
      borderRadius:     @size + 'px'
      visibility:       visibility
      background:       opts.color or 'rgba(255, 255, 255, 0.2)'
      border:           '1px solid rgba(0,0,0,0.3)'
      boxShadow:        '0 0 6px rgba(255,255,255,0.1)'
      transform:        transform
      MozTransform:     transform
      WebkitTransform:  transform
      msTransform:      transform
      transition:       transition
      MozTransition:    transition
      WebkitTransition: transition
      msTransition:     transition
    for k, s of styles
      @el.style[k] = s
    document.body.appendChild(@el)

    @getGazeElement = _.throttle =>
      [x, y] = @center()
      @el.style.visibility = 'hidden'
      el = document.elementFromPoint x, y
      @el.style.visibility = 'visible'
      el
    , 100


  center: ->
    b = @el.getBoundingClientRect()
    [parseInt(b.left + 0.5 * @size), parseInt(b.top + 0.5 * @size)]


  move: (x, y) ->
    h = 0.5 * @size
    @push 'translate', "#{+x - h}px, #{+y - h}px"


  scale: (scale = 0.7, time = 300) ->
    @push 'scale', +scale
    @scaleTimer = setTimeout =>
      @pop 'scale'
    , time


  draw: ->
    ts = []
    for t of @transforms
      ts.push "#{t}(#{@transforms[t]})" unless @transforms[t] is null

    if ts.length is 0 then t = 'none' else t = ts.join ' '

    for k in ['transform', 'MozTransform', 'WebkitTransform', 'msTransform']
      @el.style[k] = t


  push: (transform, value) ->
    @transforms[transform] = value
    @draw()


  pop: (transform) ->
    @transforms[transform] = null
    @draw
