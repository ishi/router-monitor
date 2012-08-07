$(document).ready -> 
  dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )
  $('a[data-action="add"]').on 'click', ->
    dialog.dialog('open')

  $('select#zone_method').on 'change', ->
    if $(this).val() == 'DHCP'
      $('input[data-disable-on*="method-dhcp"]').prop('disabled', true)
    else
      $('input[data-disable-on*="method-dhcp"]').prop('disabled', false)
