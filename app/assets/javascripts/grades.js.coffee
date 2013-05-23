window.classy ||= {}
#///////////////////////////////////////////////////////////////////////////////
# Extraction
#///////////////////////////////////////////////////////////////////////////////
# Grades/Student Record Page
# html - A jQuery object representing the page body
classy.extract_grades_page_data = (html) ->
  process_header_row = (row) ->
    # TODO: Regex out the fluff
    return {
      name: text_extract row.find('td:eq(0)')
      term: text_extract row.find('td:eq(1)')
      submission: text_extract row.find('td:eq(2)')
      level: text_extract row.find('td:eq(3)')
      exercises: []
    }

  process_grade_row = (row) ->
    return {
      id: parseInt(text_extract row.find('td:eq(0)'))
      type: text_extract row.find('td:eq(1)')
      title: text_extract row.find('td:eq(2)')
      set_by: text_extract row.find('td:eq(3)')
      declaration: text_extract row.find('td:eq(4)')
      extension: text_extract row.find('td:eq(5)')
      submission: text_extract row.find('td:eq(6)')
      grade: text_extract row.find('td:eq(7)')
    }

  extract_modules = (table) ->
    grade_rows = table.find('tr')
    grade_rows = grade_rows.slice(2)

    modules = []
    current_module = null;
    grade_rows.each (i, e) ->
      row_elem = $(e)
      tds = row_elem.find('td')
      if tds.length > 1 # Ignore spacer/empty rows
        if $(tds[0]).attr('colspan')
          current_module = process_header_row(row_elem)
          modules.push current_module
        else
          current_module.exercises.push process_grade_row(row_elem)

    return modules

  # TODO: Regex extract useful values
  subscription_last_updated = text_extract html.find('table:eq(7) table td:eq(1)')
  submissions_completed = text_extract html.find('table:eq(7) table td:eq(4)')
  submissions_extended = text_extract html.find('table:eq(7) table td:eq(6)')
  submissions_late = text_extract html.find('table:eq(7) table td:eq(8)')

  required_modules = extract_modules html.find('table:eq(9)')
  optional_modules = extract_modules html.find('table:eq(-2)')

  return {
    stats:
      subscription_last_updated: subscription_last_updated
      submissions_completed: submissions_completed
      submissions_extended: submissions_extended
      submissions_late: submissions_late
    required_modules: required_modules
    optional_modules: optional_modules
  }

#///////////////////////////////////////////////////////////////////////////////
# Construction
#///////////////////////////////////////////////////////////////////////////////
classy.populate_grades_page = (vars) ->

  grade_to_class = (grade) ->
    switch grade
      when "A*", "A+", "A" then "progress-success"
      when "B"  then "progress-info"
      when "C" then "progress-warning"
      when "D", "E", "F" then "progress-danger"

  grade_to_width = (grade) ->
    width = switch grade
      when "A*" then 100
      when "A+" then 89
      when "A"  then 79
      when "B"  then 69
      when "C"  then 59
      when "D"  then 49
      when "E"  then 39
      when "F"  then 29
      else 0
    "#{width}%"

  render_module = (module) ->
    module_elem = $('#module_template .row').clone()
    module_elem.find('.module-title').html(module.name)

    grades_table = module_elem.find('.module-grades')
    if module.exercises.length == 0
      grades_table.append($('<tr><td colspan="8">No exercises for this module.</td></tr>'))
    else
      $(module.exercises).each (i, exercise) ->
        exercise_elem = $('#exercise_template tr').clone()
        exercise_elem.find('.exercise-id').html(exercise.id)
        exercise_elem.find('.exercise-type').html(exercise.type)
        exercise_elem.find('.exercise-title').html(exercise.title)
        exercise_elem.find('.exercise-set-by').html(exercise.set_by)
        exercise_elem.find('.exercise-declaration').html(exercise.declaration)
        exercise_elem.find('.exercise-extension').html(exercise.extension)
        exercise_elem.find('.exercise-submission').html(exercise.submission)

        switch exercise.grade
          when ""
            exercise_elem.find('.exercise-grade-container').html("No Record")
          when "n/a"
            exercise_elem.find('.exercise-grade-container').html('<i class="icon-legal" /> Awaiting Marking')
          when "N/P"
            exercise_elem.find('.exercise-grade-container').html('<i class="icon-lock" /> Marked, Not Published')
          else
            exercise_elem.find('.progress').addClass(grade_to_class(exercise.grade))
            exercise_elem.find('.progress .bar').css('width', grade_to_width(exercise.grade))
            exercise_elem.find('.exercise-grade').html(exercise.grade)
        grades_table.append(exercise_elem)
    return module_elem

  $('#cc-subscription-updated').html(vars.stats.subscription_last_updated)
  $('#cc-submissions-completed').html(vars.stats.submissions_completed)
  $('#cc-submissions-extended').html(vars.stats.submissions_extended)
  $('#cc-submissions-late').html(vars.stats.submissions_late)

  $(vars.required_modules).each (i, module) ->
    $('#cc-required-modules').append(render_module module)

  $(vars.optional_modules).each (i, module) ->
    $('#cc-optional-modules').append(render_module module)