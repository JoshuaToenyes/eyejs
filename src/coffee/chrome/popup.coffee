chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->

  tab = tabs[0]
  enabled = document.getElementById('enabled')
  size = document.getElementById('size')

  updateStatus = (status) ->
    enabled.checked = status.enabled
    size.value = status.size

  sendMessage = (message, value) ->
    chrome.tabs.sendMessage tab.id, {msg: message, val: value}, (status) ->
      updateStatus(status)

  enabled.addEventListener 'change', ->
    m = if !enabled.checked then 'eyejs:disable' else 'eyejs:enable'
    sendMessage m

  size.addEventListener 'input', ->
    console.log this.value
    sendMessage 'eyejs:resize', this.value


  sendMessage 'eyejs:getstatus'
