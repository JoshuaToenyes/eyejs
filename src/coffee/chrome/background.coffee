makeHandler = (sendResponse) ->
  return (w) -> sendResponse 'response message'

win = null

setInterval ->
  chrome.windows.getCurrent (w) -> win = w
, 500

setInterval ->
  chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
    chrome.tabs.sendMessage tabs[0].id, win
, 500
