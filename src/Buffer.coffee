

module.exports = class Buffer

  constructor: (@size = 5) ->
    @store = []

  push: (e) ->
    @store.unshift e
    if @store.length > @size then @store.pop()

  get: (i) ->
    @store[i]
