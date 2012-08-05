$(document).ready -> 
  dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )
  $('a[data-action="add"]').on "click", ->
    dialog.dialog('open')
