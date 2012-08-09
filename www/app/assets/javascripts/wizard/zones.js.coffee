$(document).ready -> 
  dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )

  $('a[data-action="add"]').on 'click', ->
    dialog.dialog('open')

  $('a[data-action="edit"]').on 'click', ->
    form = $('div#add-form')
    data = $('table#add-destination .ui-state-hover:first').parent().children('.ui-widget-content')
    data.each ->
      $el = $(this)
      $('#zone_' + $el.data('name'), form).val($el.text())
    $('select#zone_method').change()
    dialog.dialog('open')

  $('select#zone_method').on 'change keyup', ->
    if $(this).val() == 'DHCP'
      $('input[data-disable-on*="method-dhcp"]').prop('disabled', true)
    else
      $('input[data-disable-on*="method-dhcp"]').prop('disabled', false)
