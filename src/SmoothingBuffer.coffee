

module.exports = class SmoothingBuffer

  constructor: (@size, @alpha, @min) ->
    @store = []
    for i in [0...@size]
      @store.push 0

  push: (v) ->
    s = @smooth v
    if Math.abs(s - @top()) < @min then return
    @store.unshift @smooth(v)
    if @store.length > @size then @store.pop()


  ##
  # Returns the current smoothed value.

  top: -> @store[0]


  ##
  # Returns the exponentially smoothed value of v.
  #
  # @see http://en.wikipedia.org/wiki/Exponential_smoothing#The_exponential_moving_average

  smooth: (v) ->
    @alpha * v + @store[0] - @alpha * @store[0]
