EventEmitter = (require 'events').EventEmitter

THRESHOLD = 400

module.exports = class BlinkController extends EventEmitter

  constructor: ->
    @_state = 'open'
    @_lastOpen = new Date()
    @_lastClose = new Date()

  pushOpen: ->
    @_lastOpen = new Date()
    if @_state is 'open' then return
    if @_lastOpen - @_lastClose > THRESHOLD
      @_state = 'open'
      @emit 'open'

  pushClose: ->
    @_lastClose = new Date()
    if @_state is 'closed' then return
    if @_lastClose - @_lastOpen > THRESHOLD
      @_state = 'closed'
      @emit 'close'
