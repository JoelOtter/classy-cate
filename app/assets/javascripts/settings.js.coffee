$ -> 
  console.log 'trying'
  $.ajax
    type: 'GET'
    url: '/skins/index'
    dataType: 'html'
    success: (data) ->
      @MAIN_PAGE_HTML = $(data).find('#main')
      @GRADES_PAGE_HTML = $(data).find('#grades').wrap('<p>').html()
      @EXERCISES_PAGE_HTML = $(data).find('#exercises').wrap('<p>').html()
      window.initial_load()
