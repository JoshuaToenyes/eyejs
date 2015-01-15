
EventEmitter = (require 'events').EventEmitter

class Manager extends EventEmitter

  constructor: ->

  reconnection: ->

  reconnectionAttempts: ->

  reconnectionDelay: ->

  reconnectionDelayMax: ->

  timeout: ->



class Socket extends EventEmitter

  constructor: (@url, @opts) ->
    @io = new Manager()



# Easily add a spy to the module function.
module.exports.spy = null

module.exports = (url, opts) ->
  if module.exports.spy then module.exports.spy.apply(this, arguments)
  return module.exports.socket

module.exports.reset = ->
  module.exports.socket = new Socket()

module.exports.Socket = Socket
module.exports.Manager = Manager

module.exports.reset()
