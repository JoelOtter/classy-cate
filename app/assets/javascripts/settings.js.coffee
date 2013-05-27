$ -> 
  $.get '/skins/index', (page) ->
    window.DASHBOARD = $(page).find('#dashboard').clone()
    window.EXERCISES = $(page).find('#exercises').clone()
    window.GRADES = $(page).find('#grades').clone()
    window.initial_load()
