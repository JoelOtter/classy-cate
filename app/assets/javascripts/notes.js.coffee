window.classy ||= {}
#///////////////////////////////////////////////////////////////////////////////
# Extraction
#///////////////////////////////////////////////////////////////////////////////
# Notes Page for Module
# html - A jQuery object representing the page body
classy.extract_notes_page_data = (html) ->

  process_notes_rows = (html) ->
    html.find('table [cellpadding="3"]').find('tr')[1..]

  notes = []
  for row in ($(r) for r in process_notes_rows html)
    title = row.find('td:eq(1)').text()
    link = $(row.find('td:eq(1) a'))
    if link.attr('href')? && link.attr('href') != ''
      notes.push {
        type: "resource"
        title: title
        link: link.attr('href')
      }
    else if link.attr('onclick')? # Remote page
      identifier = link.attr('onclick').match(/clickpage\((.*)\)/)[1]
      href = "showfile.cgi?key=2012:3:#{identifier}:c3:NOTES:peh10"
      notes.push {
        type: "url"
        title : title
        link : href
      }

  return { notes: notes }

#///////////////////////////////////////////////////////////////////////////////
# Construction
#///////////////////////////////////////////////////////////////////////////////
classy.populate_notes = (notes_data, header) ->
  notes_header = $('#notes-modal-header')
  notes_header.find('h3').remove()
  notes_header.append("<h3>#{header}</h3>")
  notes_body = $("#notes-modal-tbody")
  notes_body.html('')
  for note, i in notes_data.notes
    row = $('<tr/>')
    row.append("<td>#{i+1}</td>")
    if note.type == "url"
      row.append("<td><a href='#{note.link}' target='_blank'>#{note.title}</a></td>")
    else
      row.append("<td><a href='#{note.link}'>#{note.title}</a></td>")
    notes_body.append(row)