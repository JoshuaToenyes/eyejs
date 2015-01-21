io = require 'socket.io-client'


module.exports =

  connect: ->
    socket = io('http://localhost:3000')

    # Incoming eye-tracking frame handler.
    socket.on 'frame', window.Eye.handleFrame
