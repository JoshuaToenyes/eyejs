module.exports =

  makeElement: (tag, styles) ->
    el = document.createElement tag
    for k, s of styles
      el.style[k] = s
    el
