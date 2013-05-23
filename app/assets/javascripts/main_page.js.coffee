window.classy ||= {}
#///////////////////////////////////////////////////////////////////////////////
# Extraction
#///////////////////////////////////////////////////////////////////////////////
# CATE Homepage
# html - A jQuery object representing the page body
classy.extract_main_page_data = (html) ->
  current_url = document.URL
  current_year = current_url.match("keyp=([0-9]+)")[1] #TODO: Error check
  current_user = current_url.match("[0-9]+:(.*)")[1] # TODO: Error Check

  version = html.find('table:first td:first').text()

  profile_image_src = html.find('table:eq(2) table:eq(1) tr:eq(0) img').attr('src')

  profile_fields = html.find('table:eq(2) table:eq(1) tr:eq(1) td').map (i, e) -> $(e).text()
  first_name = profile_fields[0]
  last_name = profile_fields[1]
  login = profile_fields[2]
  category = profile_fields[3]
  candidate_number = profile_fields[4]
  cid = profile_fields[5]
  personal_tutor = profile_fields[6]

  available_years = html.find('select[name=newyear] option').map (index, elem) ->
    elem = $(elem)
    {text: elem.html(), href: elem.attr('value')}
  available_years = available_years.slice(1)

  other_func_links = html.find('table:eq(2) table:eq(9) tr td:nth-child(3) a').map (index, elem) ->
    $(elem).attr('href')

  grading_schema_link = other_func_links[0]
  documentation_link = other_func_links[1]
  extensions_link = other_func_links[2]
  projects_portal_link = other_func_links[3]
  individual_records_link = other_func_links[4]

  default_class = html.find('input[name=class]:checked').val()
  default_period = html.find('input[name=period]:checked').val()

  keyt = html.find('input[type=hidden]').val()

  timetable_url = '/timetable.cgi?period=' + default_period + '&class=' + default_class + '&keyt=' + keyt

  return {
    current_url: current_url
    current_year: current_year
    current_user: current_user
    version: version
    profile_image_src: profile_image_src
    first_name: first_name
    last_name: last_name
    login: login
    category: category
    candidate_number: candidate_number
    cid: cid
    personal_tutor: personal_tutor
    available_years: available_years
    grading_schema_link: grading_schema_link
    documentation_link: documentation_link
    extensions_link: extensions_link
    projects_portal_link: projects_portal_link
    individual_records_link: individual_records_link
    default_class: default_class
    default_period: default_period
    keyt: keyt
    timetable_url: timetable_url
  }


#///////////////////////////////////////////////////////////////////////////////
# Construction
#///////////////////////////////////////////////////////////////////////////////
classy.populate_main_page = (vars) ->
  $('#cc-identity-profile-image').attr('src', vars.profile_image_src)
  $('#cc-identity-first-name').html(vars.first_name)
  $('#cc-identity-last-name').html(vars.last_name)
  $('#cc-identity-login').html(vars.login)
  $('#cc-identity-category').html(vars.category)
  $('#cc-identity-candidate-number').html(vars.candidate_number)
  $('#cc-identity-cid').html(vars.cid)
  $('#cc-identity-personal-tutor').html(vars.personal_tutor)

  vars.available_years.each (i, val) ->
    $('#cc-year-dropdown').append '<li><a href="' + val.href + '">' + val.text + '</a></li>'

  $('#cc-other-projects-portal').attr('href', vars.projects_portal_link)
  $('#cc-other-extensions').attr('href', vars.extensions_link)
  $('#cc-other-documentation').attr('href', vars.documentation_link)

  $('#class-selector li').bind 'click', ->
    $('#current-class')
      .text($(this).text())
      .attr('value',$(this).find('a').attr('value'))
  $('#ex-go-btn').data('keyt',vars.keyt)

  $('#ex-go-btn').bind 'click', ->
    p = $('#term-selector .active').attr 'value'
    c = $('#current-class').attr 'value'
    kt = $(this).data('keyt')
    url = "/timetable.cgi?period=#{p}&class=#{c}&keyt=#{kt}"
    load_exercises_page(null, null, null, url)

  if (period = parseInt vars.default_period)%2 == 0 then period = period - 1
  $('#current-class').attr 'value', vars.default_class
  $('#class-selector a').each ->
    if $(this).attr('value') == vars.default_class
      $('#current-class').text($(this).text()) 
  $('#term-selector .btn').each ->
    $(this).addClass('active') if $(this).attr('value') == period.toString()

  lower = new Date()
  upper = new Date(lower.getTime() + 1000*60*60*24*7 + 1)  # to include full day
  load_cate_page $('#nav-exercises').attr('href'), (body) ->
    vars = extract_exercise_page_data body
    [exs_due, exs_late] = [[],[]]
    for m in vars.modules
      for e in m.exercises
        if lower <= e.end <= upper then exs_due.push e
        else if e.end < lower and e.handin? then exs_late.push e
    if exs_due.length != 0
      [vars, fake_module] = [{},{}]
      fake_module.exercises = exs_due
      vars.modules = [fake_module]
      exs = (populate_exercises_page vars, true).sort (a,b) ->
        a.end - b.end
      $('#exercises_table').append(e.row) for e in exs
      create_timeline
        structure : TIMELINE_STRUCTURE, moments : exs
        destination : $('#exercise_timeline')
      $('#exercises_table th').css('cursor','pointer').click -> 
        $('#exercise_timeline .circle.origin').trigger 'click'
      for e in exs
        day = 1000*60*60*24
        [tomorrow, c] = [new Date(lower.getTime() + day), '']
        if (e.end < tomorrow) 
          c = 'label-important'
        else if (e.end < (new Date(tomorrow.getTime() + 2*day)))
          c = 'label-warning'
        due_cell = e.row.find('.due')
        label = $("<span class='label'>#{due_cell.text()}</span>")
        label.addClass(c + ' due_label')
        due_cell.html('').append label
        e.row.data 'bubble', e.info_box
        e.row.hover \
          (-> $(this).data('bubble').trigger('mouseenter')), \
          (-> $(this).data('bubble').trigger('mouseleave'))
        e.row.click -> $(this).data('bubble').trigger('click')
        e.row.css 'cursor', 'pointer'
    else populate_exercises_page null, true