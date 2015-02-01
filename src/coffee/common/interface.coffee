

getStatus = ->
  return {
    enabled: Eye.enabled
    size: Eye.indicator.size
    opacity: Eye.indicator.opacity()
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
        Eye.indicator.resize +request.val

      when 'eyejs:setopacity'
        Eye.indicator.opacity +request.val

    sendResponse getStatus()
