expect      = (require 'chai').expect
sinon       = require 'sinon'
testability = (require 'browserify-testability')(require)
fakeio      = require './doubles/socket-io'
eye         = require './../dist/eye'

eye = null

describe 'eye.js tests', ->

  beforeEach ->
    fakeio.reset()
    eye = testability.require('./../dist/eye', {
      'socket.io-client': fakeio
    })

  it 'runs tests', ->
