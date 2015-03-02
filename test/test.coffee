expect      = (require 'chai').expect
sinon       = require 'sinon'
testability = (require 'browserify-testability')(require)
fakeio      = require './doubles/socket-io'
eyejs       = require './../eyejs'

eye = null

describe 'eye.js tests', ->

  beforeEach ->
    fakeio.reset()
    eyejs = testability.require('./../eyejs', {
      'socket.io-client': fakeio
    })

  it 'runs tests', ->
