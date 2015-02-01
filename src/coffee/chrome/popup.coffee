chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->

  tab = tabs[0]
  enabled = document.getElementById('enabled')
  size = document.getElementById('size')
  opacity = document.getElementById('opacity')
  calibrate = document.getElementById('calibrate')

  updateStatus = (status) ->
    enabled.checked = status.enabled
    size.value = status.size
    opacity.value = status.opacity

  sendMessage = (message, value) ->
    chrome.tabs.sendMessage tab.id, {msg: message, val: value}, (status) ->
      updateStatus(status)

  enabled.addEventListener 'change', ->
    m = if !enabled.checked then 'eyejs:disable' else 'eyejs:enable'
    sendMessage m

  size.addEventListener 'input', ->
    sendMessage 'eyejs:resize', this.value

  opacity.addEventListener 'input', ->
    sendMessage 'eyejs:setopacity', this.value

  calibrate.addEventListener 'click', ->
    sendMessage 'eyejs:calibrate'

  sendMessage 'eyejs:getstatus'
