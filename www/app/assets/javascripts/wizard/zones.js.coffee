$(document).ready -> 
  window.dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )


  $(document).on 'click', 'a[data-action="add"]', ->
    form = $('div#add-form')
    form.find('table input').val('')
    form.find('table select').val('')
    $('div#add-form').dialog('open')
    $('#zone_old_name', form).val('')

  $(document).on 'click', 'a[data-action="edit"], ', ->
    $row = $('table#add-destination .ui-state-hover:first').parent()
    return unless $row.length
    zone = $row.data 'zone'
    form = $('div#add-form')
    $('#zone_old_name', form).val(zone.name)
    for type, value of zone
      $('#zone_' + type, form).val(value)
    $('select#zone_method').change()
    $('div#add-form').dialog('open')

  $(document).on 'click', 'a[data-action="delete"]', ->
    $row = $('table#add-destination .ui-state-hover:first').parent()
    zone = $row.data 'zone'
    jQuery.ajax('/wizard/zones', 
      {
        type: 'DELETE', 
        data: { zone: { name: zone.name, type: zone.type, interface: zone.interface } }
      })

  $(document).on 'change keyup', 'select#zone_method', ->
    if $(this).val() == 'DHCP'
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', true)
    else
      form = $('div#add-form')
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', false)
      if $('#zone_type', form).val() != 'WAN'
        $('input[data-disable-on*="method-static-lan"]').prop('readonly', true)


  $(document).on 'submit', 'form#new_zone', ->
    int = $('select#zone_interface').val()
    $row = $('table#add-destination .ui-state-hover:first').parent()
    $rows = $('table#add-destination tr').not($row.get())
    for curr in $rows
      continue if !$(curr).data('zone')
      if $(curr).data('zone').interface is int
        return confirm('Wybrany interfejs jest powiązany z inną strefą. Czy przenieść interfejs do tej strefy?')
       
