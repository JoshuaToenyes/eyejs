


module.exports = class Buffer

  constructor: (@size = 5) ->
    @store = []

  push: (e) ->
    @store.unshift e
    if @store.length > @size then @store.pop()
    console.log @store

  get: (i) ->
    if i >= 0
      @store[i]
    else
      @store[@store.length + i]

  remove: (i) ->
    @store.splice i, 1
