io = require 'socket.io-client'


module.exports =

  connect: ->

    @socket = io('https://localhost:3000')

    # Incoming eye-tracking frame handler.
    @socket.on 'frame', window.Eye.handleFrame

  send: (e, m) ->
    @socket.emit(e, m)
