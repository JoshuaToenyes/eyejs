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

    @ws.onmessage = (e) => @handleMessage(e)


  send: (e, m) ->
    @socket.send(e, m)


  ##
  # Handles incomming messages from the EyeJS WebSocket server (which provides
  # eye-tracking data).
  handleMessage: (e) ->
    try
      msg = JSON.parse(e.data)
      switch msg.type
        when 'gaze'
          @emit('gaze', msg)
    catch err
      console.error 'Failed to parse message data from WebSocket server.'
