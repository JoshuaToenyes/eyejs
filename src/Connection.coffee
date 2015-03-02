EventEmitter = (require 'events').EventEmitter

module.exports = class Connection extends EventEmitter

  constructor: (@opts = {}) ->
    @opts.host   ?= 'localhost'
    @opts.port   ?= 5619
    @opts.secure ?= false
    @opts.path   ?= ''


  connect: ->

    protocol = if @opts.secure then 'wss' else 'ws'
    url = "#{protocol}://#{@opts.host}:#{@opts.port}"

    @ws = new WebSocket url

    @ws.onMessage = @handleMessage


  send: (e, m) ->
    @socket.send(e, m)


  handleMessage: (e) ->
    switch e.type
      when 'frame' then @emit(frame, e)
