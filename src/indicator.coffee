
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
    transition = opts.transition or 'all 0.1s ease-out'
    visibility = opts.visible ? 'visible' : 'hidden'

    @transforms = {}
    @size = +opts.size or 20
    @scaleTimer = null

    @el = document.createElement('div')
    @el.style =
      position:         'fixed',
      height:           @size,
      width:            @size,
      top:              0,
      left:             0,
      borderRadius:     @size,
      visibility:       visibility,
      background:       opts.color or 'rgba(160, 0, 0, 0.3)',
      transform:        transform,
      MozTransform:     transform,
      WebkitTransform:  transform,
      msTransform:      transform,
      transition:       transition,
      MozTransition:    transition,
      WebkitTransition: transition,
      msTransition:     transition

    document.body.appendChild(@el)


  center: ->
    b = @el.getBoundingClientRect()
    [b.left + 0.5 * @size, b.top + 0.5 * @size]


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
    for t in @transforms
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
