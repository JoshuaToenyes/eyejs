

getStatus = ->
  return {
    enabled: Eye.enabled
    size: Eye.indicator.size
  }


if chrome?

  chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->

    switch request.msg
      when 'eyejs:enable'
        Eye.enable()

      when 'eyejs:disable'
        Eye.disable()

      when 'eyejs:getstatus' then null

      when 'eyejs:resize'
        console.log 'resizing...', +request.val
        Eye.indicator.resize +request.val

    sendResponse getStatus()
