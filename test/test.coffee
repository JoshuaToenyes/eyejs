expect      = (require 'chai').expect
sinon       = require 'sinon'
testability = (require 'browserify-testability')(require)
fakeio      = require './doubles/socket-io'
eye         = require './../common/eye'

eye = null

describe 'eye.js tests', ->

  beforeEach ->
    fakeio.reset()
    eye = testability.require('./../common/eye', {
      'socket.io-client': fakeio
    })

  it 'runs tests', ->
