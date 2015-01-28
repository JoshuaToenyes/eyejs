document.addEventListener 'DOMContentLoaded', ->
  script = document.createElement( 'script' )
  script.type = 'text/javascript'
  script.src =  chrome.extension.getURL('eye.js')
  script.id = 'eyejs-script'
  script.setAttribute('data-app-id', chrome.runtime.id)
  document.head.appendChild(script)
