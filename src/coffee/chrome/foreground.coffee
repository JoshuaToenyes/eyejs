left = null
top  = null

setInterval ->
  chrome.runtime.sendMessage {type: 'getWindow'}, (response) ->
    changed = false
    if response.top != top
      changed = true
      top = response.top
    if response.left != left
      changed = true
      left = response.left
    if changed
      console.log 'top/left:', top, left
, 500

document.addEventListener 'DOMContentLoaded', ->

  script = document.createElement( 'script' )
  script.type = 'text/javascript'
  script.src =  chrome.extension.getURL('eye.js')
  document.head.appendChild(script)
