chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request.type is 'getWindow'
    chrome.windows.getCurrent (window) ->
      sendResponse window
