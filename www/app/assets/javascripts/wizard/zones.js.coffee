$(document).ready -> 
  dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )

  form = $('div#add-form')

  $('a[data-action="add"]').on 'click', ->
    form.find('table input').val('')
    form.find('table select').val('')
    dialog.dialog('open')
    $('#zone_old_name', form).val('')

  $('a[data-action="edit"]').on 'click', ->
    $row = $('table#add-destination .ui-state-hover:first').parent()
    return unless $row.length
    zone = $row.data 'zone'
    $('#zone_old_name', form).val(zone.name)
    for type, value of zone
      $('#zone_' + type, form).val(value)
    $('select#zone_method').change()
    dialog.dialog('open')

  $('a[data-action="delete"]').on 'click', ->
    $row = $('table#add-destination .ui-state-hover:first').parent()
    zone = $row.data 'zone'
    jQuery.ajax('/wizard/zones', 
      { 
        type: 'DELETE', 
        data: { 
          zone: { 
            name: zone.name, 
            type: zone.type}}})

  $('select#zone_method').on 'change keyup', ->
    if $(this).val() == 'DHCP'
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', true)
    else
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', false)
      if $('#zone_type', form).val() != 'WAN'
        $('input[data-disable-on*="method-static-lan"]').prop('readonly', true)
