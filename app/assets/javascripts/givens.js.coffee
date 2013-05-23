window.classy ||= {}
#///////////////////////////////////////////////////////////////////////////////
# Extraction
#///////////////////////////////////////////////////////////////////////////////
# Givens Page for Exercise
# html - A jQuery object representing the page body
classy.extract_givens_page_data = (html) ->

  categories = []

  # Select the tables
  html.find('table [cellpadding="3"]')[2..].each(->
    category = {}
    if $(this).find('tr').length > 1  # Only process tables with content
      category.type = $(this).closest('form').find('h3 font').html()[..-2]
      rows = $(this).find('tr')[1..]
      category.givens = []
      for row in rows
        if (cell = $(row).find('td:eq(0) a')).attr('href')?
          category.givens.push {
            title : cell.html()
            link  : cell.attr('href')
          }
      categories.push category
    )    

  # Return an array of categories, each element containing a type and rows
  # categories = [ { type = 'TYPE', givens = [{title, link}] } ]
  return categories


#///////////////////////////////////////////////////////////////////////////////
# Construction
#///////////////////////////////////////////////////////////////////////////////
classy.populate_givens = (givens_data, header) ->
  # givens_data = [ { type = 'TYPE', givens = [{title, link}] } ]
  givens_header = $('#givens-modal-header')
  givens_header.find('h3').remove()
  givens_header.append("<h3>#{header}</h3>")
  givens_table = $('#givens-table')
  givens_table.html('')
  for category in givens_data
    head = $('<thead/>').append $("<tr><th colspan='2'><h4>#{category.type}</h4></th></tr>")
    head.append $('<tr><th class="id">ID</th><th>Link</th></tr>')
    tbody = $('<tbody/>')
    for given, i in category.givens
      row = $('<tr/>')
      row.append("<td>#{i+1}</td>")
      row.append("<td><a href='#{given.link}'>#{given.title}</a></td>")
      tbody.append row
    givens_table.append(head)
    givens_table.append(tbody)