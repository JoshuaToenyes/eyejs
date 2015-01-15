io = require 'socket.io-client'

Buffer = require './buffer'

socket = io('http://localhost:3000')

opens     = new Buffer()
closes    = new Buffer()
lastFrame = null

# Incoming eye-tracking frame handler.
socket.on 'frame', (frame) ->

  if window.Eye.frozen then return

  if lastFrame

    closedThisFrame = frame.avg.x == 0 and frame.avg.y == 0
    openLastFrame   = lastFrame.avg.x != 0 and lastFrame.avg.y != 0

    closedLastFrame = lastFrame.avg.x == 0 and lastFrame.avg.y == 0
    openThisFrame   = frame.avg.x != 0 and frame.avg.y != 0

    if closedThisFrame and openLastFrame
      closes.push(new Date());

    if closedLastFrame and openThisFrame
      opens.push(new Date());

  lastFrame = frame

  # Handle blinks and winks here....

  if frame.avg.x != 0 and frame.avg.y != 0
    window.Eye.indicator.move frame.avg.x, frame.avg.y


module.exports = ->
