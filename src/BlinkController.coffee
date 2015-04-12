EventEmitter = (require 'events').EventEmitter

THRESHOLD = 200

module.exports = class BlinkController extends EventEmitter

  constructor: ->
    @_state = 'open'
    @_lastOpen = new Date()
    @_lastClose = new Date()
    @_opened = new Date()
    @_closed = new Date()

  pushOpen: ->
    @_lastOpen = new Date()
    if @_state is 'open' then return
    if @_lastOpen - @_lastClose > THRESHOLD
      @_state = 'open'
      @emit 'open', @_lastOpen - @_closed
      @_opened = @_lastOpen

  pushClose: ->
    @_lastClose = new Date()
    if @_state is 'closed' then return
    if @_lastClose - @_lastOpen > THRESHOLD
      @_state = 'closed'
      @emit 'close', @_lastClose - @_opened
      @_closed = @_lastClose
