bs_collapse = false

$(document).ready ->
  update_navbar()

$(document).on 'scroll', ->
  update_navbar()

update_navbar = ->
  x = $('body').scrollTop()
  y = (60-x)/2
  z = x/60
  y = 0 if y < 0
  z = 1 if z > 1
    
  $('#nav').css 'padding': y+'px 50px'
  if bs_collapse == false
    $('#nav').css 'background-color': 'rgba(255, 255, 255, '+z+')', 'box-shadow': 'rgba(0, 0, 0, '+z/3.3+') 0 0 3px 2px'
  return

$('.collapse').on 'show.bs.collapse', (e) ->
  bs_collapse = true
  $('#nav').css 'background-color': 'rgba(255, 255, 255, 1)', 'box-shadow': 'rgba(0, 0, 0, 0.33) 0 0 3px 2px'
  return

$('.collapse').on 'hide.bs.collapse', (e) ->
  bs_collapse = false
  update_navbar()
  return