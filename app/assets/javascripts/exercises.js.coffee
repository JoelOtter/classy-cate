window.classy ||= {}
#///////////////////////////////////////////////////////////////////////////////
# Extraction
#///////////////////////////////////////////////////////////////////////////////
# Excercise Page
# html - A jQuery object representing the page body
classy.extract_exercise_page_data = (html) ->

  # Extracts full title e.g. Spring Term 2012-2013
  extract_term_title = (html) ->
    html.find('tr').eq(0).find('h1').eq(0).text()

  # Converts a CATE style date into a JS Date object
  # e.g. '2013-1-7' -> Mon Jan 07 2013 00:00:00 GMT+0000 (GMT)
  parse_date = (input) ->
    [year, month, day] = input.match(/(\d+)/g)
    new Date(year, month - 1, day) # JS months index from 0

  # Extracts the academic years applicable
  # e.g. "Easter Period 2012-2013" -> ["2012", "2013"]
  extract_academic_years = (body) ->
    body.find('h1').text()[-9..].split('-')

  extract_start_end_dates = (fullTable, years) ->
    # Converts a month into an int (indexed from 1)
    # e.g. "January" -> 1
    # month - Month name as a capitalised string
    month_to_int = (m) ->
      months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
                'August', 'September', 'October', 'November', 'December']
      return 6 if m == 'J'
      rexp = new RegExp(m,'g')
      for month,i in months
            if rexp.test(month) then return i+1

    # Extracts months from table row
    # e.g. ["January", "February", "March"]
    # table_row - The Timetable table row jQuery Object
    extract_months = (table_row) ->
      table_headers = ($(cell) for cell in table_row.find('th'))
      month_cells = (c for c in table_headers when c.attr('bgcolor') == "white")
      month_names = (c.text().replace(/\s+/g, '') for c in month_cells)
      month_ids = month_names.map month_to_int
      return month_ids

    # Extracts days from table row
    # e.g. ["1", "2", "3"]
    # table_row - The Timetable table row jQuery Object
    extract_days = (table_row) ->
      table_headers = ($(cell) for cell in table_row.find('th'))
      days_text = (c.text() for c in table_headers)
      valid_days = (d for d in days_text when d.replace(/\s+/g, '') != '') 
      days_as_ints = valid_days.map parseFloat # Parse int was going nuts, '23' -> 54???
      return days_as_ints

    # TODO: What if the timetable crosses year boundaries?
    #       e.g over new year/christmas?

    [first_month, others..., last_month] = extract_months $(fullTable).find('tr').eq(0)

    year = if first_month < 9 then years[1] else years[0]

    day_headers = $(fullTable).find('tr').eq(2).find('th')

    col_buf = 0
    col_buf += 1 while $(day_headers[col_buf]).is(":empty")

    [first_day, others..., last_day] = extract_days $(fullTable).find('tr').eq(2)

    return {  # remember _day in yyyy-mm-dd format
      start: year + '-' + first_month + '-' + first_day
      end: year + '-' + last_month + '-' + last_day
      colBufferToFirst: col_buf - 1
    }

  # Extracts module details from a cell jQuery object
  process_module_cell = (cell) ->
    [id, name] = cell.text().split(' - ')
    return {
      id : id
      name : name.replace(/^\s+|\s+$/g, '')
      notesLink : cell.find('a').eq(0).attr('href')
    }

  # Add the parsed exercises to the given module
  # module - the module to attach the exercises to
  # exercise_cells - An array of cells (jQuery objects)
  process_exercises_from_cells = (module, exercise_cells) ->
    if not exercise_cells? then return null
    module.exercises ?= []

    current_date = parse_date dates.start
    current_date.setDate(current_date.getDate() - dates.colBufferToFirst)
    for ex_cell in exercise_cells
      colSpan = parseInt($(ex_cell).attr('colspan') ? 1)
      colSpan = 1 if colSpan == NaN
      if $(ex_cell).attr('bgcolor')? and $(ex_cell).find('a').length != 0
        [id, type] = $(ex_cell).find('b').eq(0).text().split(':')
        hrefs = ($(anchor).attr('href') for anchor in $(ex_cell).find('a') when $(anchor).attr('href')?)
        [mailto, spec, givens, handin] = [null, null, null, null]
        for href in hrefs
          if /mailto/i.test(href)
            mailto = href
          else if /SPECS/i.test(href)
            spec = href
          else if /given/i.test(href)
            givens = href
          else if /handins/i.test(href)
            handin = href

        end = new Date(current_date.getTime())
        end.setDate(end.getDate() + colSpan - 1)
        exercise_data = {
          id : id, type : type, start : new Date(current_date.getTime())
          end : end, moduleName : module.name
          name : $(ex_cell).text()[(id.length + type.length + 2)..].replace(/^\s+|\s+$/g,'')
          mailto : mailto, spec : spec, givens : givens, handin : handin
        }

        module.exercises.push(exercise_data)
      current_date.setDate (current_date.getDate() + colSpan)

  extract_module_exercise_data = (fullTable) ->

    # Returns whether or not an element is a module container
    # elem - jQuery element
    is_module = (elem) ->
      elem.find('font').attr('color') == "blue"

    allRows = $(fullTable).find('tr')
    modules = []
    count = 0
    while count < allRows.length
      current_row = allRows[count]
      following_row_count = 0
      module_elem = $($(current_row).find('td').eq(1))
      if is_module(module_elem)
        module_data = process_module_cell module_elem

        following_row_count = $(current_row).find('td').eq(0).attr('rowspan') - 1
        following_rows = allRows[count+1..count+following_row_count]

        exerciseCells = ($(row).find('td')[1..] for row in following_rows)
        exerciseCells.push($(current_row).find('td')[4..])
        exerciseCells = (cs for cs in exerciseCells when cs?)

        process_exercises_from_cells(module_data, cells) for cells in exerciseCells

        modules.push module_data
      count += following_row_count + 1
    return modules

  term_title = extract_term_title html
  timetable = (tb for tb in html.find('table') when $(tb).attr('border') == "0")
  dates = extract_start_end_dates timetable, extract_academic_years html   # WRONG
  modules = extract_module_exercise_data timetable
  m.exercises.sort ((a,b) -> if a.start < b.start then -1 else 1) for m in modules
  return {
    modules : modules
    start : dates.start, end : dates.end
    term_title : term_title
  }

#///////////////////////////////////////////////////////////////////////////////
# Construction
#///////////////////////////////////////////////////////////////////////////////
classy.populate_exercises_page = (vars, forDashboard) ->

  format_date = (d) ->
    pad = (a,b) ->
      (1e15+a+"").slice(-b)
    pad(d.getDate(),2) + '/' + pad(d.getMonth()+1,2) + '/' + d.getFullYear()

  populate_exercise_row = (row, ex) ->
    id_cell = row.find('.id')
    if forDashboard?
      id_cell.text(ex.moduleName)
      id_cell = row.find('.name') 
    if ex.handin?
        id_cell.html('')
        handin_anchor = $(document.createElement('a'))
          .attr('href',ex.handin).html('Hand in').appendTo(id_cell)
        handin_anchor.addClass(
          if ex.end > (new Date()) then 'handin_link btn btn-primary' else 'btn btn-danger late_handin')
    else
      if not forDashboard? or !/\S/.test(ex.name)
        id_cell.html('{'+ex.id+':'+ex.type+'}') 
      else id_cell.html('')
    if /\S/.test(ex.name)
      name_cell = row.find('td.name')
      if not forDashboard?
        name_cell.text(ex.name)
      else name_cell.html(name_cell.html() + ex.name)
      
    row.find('td.set').text(format_date ex.start)
    due_text = format_date ex.end
    if forDashboard?
      [day, month, date] = ex.end.toString().split(' ')
      due_text = day + ' ' + date

    row.find('td.due').text due_text
    row.find('td.due').text

    if ex.spec?
      (specCell = row.find('.spec')).text('')
      ex.spec_element = $(document.createElement('a')).attr('href',ex.spec).html('Spec Link').appendTo(specCell)

    if ex.givens?
      givensCell = row.find('.given').text('')
      ex.given_element = $(document.createElement('a')).attr('href',ex.givens)
        .html('Givens').appendTo(givensCell)
        .data('ex_title', row.find('.name').text())
        .bind 'click', (e) ->
          e.preventDefault()
          url = $(this).attr 'href'
          $('#active_given').removeAttr 'id'
          $(this).attr 'id', 'active_given'
          load_cate_page url, (body) ->
            givens_data = extract_givens_page_data(body)
            populate_givens(givens_data, $('#active_given').data('ex_title'))
            $('#givens-modal').modal('show')


  destination_div = $('#page-content')
  destination_div = $('#exercise-timeline') if forDashboard?
  (modules = vars.modules) if vars?
  if not forDashboard?
    $('#term_title').text('Timetable - ' + vars.term_title)


  if vars? then for module in (m for m in modules when m.exercises[0]?) # Ignore empty module  
    if not forDashboard?
      module_header = $('<h3>' + module.id + ' - ' + module.name + '</h3>') 

    if module.notesLink? and not forDashboard?
      note_link = $('<a/>').attr('href', module.notesLink).html('Notes')
        .data('module_title',module_header.text())  # Save title link for modal

      note_link.bind 'click', (e) ->
          e.preventDefault()
          url = $(this).attr 'href'
          $('#active_note').removeAttr 'id'
          $(this).attr 'id', 'active_note'
          load_cate_page url, (body) ->
            notes_data = extract_notes_page_data(body)
            populate_notes(notes_data, $('#active_note').data('module_title'))
            $("#notes-modal").modal('show')
      module_header.append(" - ").append(note_link)

    module_table = $('#exercises_table')
    if not forDashboard? 
      module_table = $('#exercises_template').clone()
    module_table.removeClass('hidden')

    for exercise in module.exercises
      row = $('#exercise_row_template').clone()
      if not forDashboard?
        row.removeClass('hidden').appendTo(module_table)
      else exercise.row = row.removeClass('hidden')  # rememeber to append
      populate_exercise_row row, exercise
    destination_div.append(module_header).append(module_table) if not forDashboard?

    if forDashboard? then return module.exercises

    placeholder = $('<div/ class="timeline_slider">').appendTo destination_div
    timeline = create_timeline
              destination : placeholder
              structure : TIMELINE_STRUCTURE, moments : module.exercises
    .hide()

    timeline_icon = $('<i/ rel="tooltip" title="Toggle timeline" class="icon-time timeline_toggle">')
      .data 
        'clicked' : false
        'timeline' : timeline
        'placeholder' : placeholder
      .bind 'click', ->
        $(this).data 'clicked', (clicked = !$(this).data 'clicked')
        [timeline, placeholder] = [$(this).data('timeline'), $(this).data('placeholder')]
        if clicked
          placeholder.animate {minHeight : 150}, {duration : 400, complete : -> timeline.fadeIn()}
        else
          timeline.fadeOut
            complete : -> placeholder.animate {minHeight : 0, height : 'auto'}, {duration : 400}
      .tooltip {placement : 'left', delay : {show : 500, hide : 100}}

    module_header.append timeline_icon

  if not modules? or Math.max((m.exercises.length for m in vars.modules)...) <= 0
    no_modules = $('<div/>').css
      textAlign : 'center', paddingTop : '50px', paddingBottom : '50px'
    .append $('<div/ class="well">').append("<h4>There's no handins here!</h4>")
    $('#page-content').append no_modules

  if not forDashboard?
    $('#back_term_btn').bind 'click', ->
        if PERIOD != 1 then load_exercises_page null, null, -1
    $('#next_term_btn').bind 'click', ->
        if PERIOD != 6 then load_exercises_page null, null, 1

