$(document).ready -> 
  dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )

  $('a[data-action="add"]').on 'click', ->
    dialog.dialog('open')
    $('#zone_old_name', form).val('')

  $('a[data-action="edit"]').on 'click', ->
    form = $('div#add-form')
    data = $('table#add-destination .ui-state-hover:first').parent().children('.ui-widget-content')
    data.each ->
      $el = $(this)
      $('#zone_old_name', form).val($el.text()) if $el.data('name') == 'name'
      $('#zone_' + $el.data('name'), form).val($el.text())
    $('select#zone_method').change()
    dialog.dialog('open')

  $('select#zone_method').on 'change keyup', ->
    if $(this).val() == 'DHCP'
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', true)
    else
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', false)
