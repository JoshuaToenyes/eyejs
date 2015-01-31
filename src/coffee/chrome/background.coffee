

chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
  console.log 'got current tab: ', tabs[0]
  #chrome.tabs.sendMessage tabs[0].id, win
