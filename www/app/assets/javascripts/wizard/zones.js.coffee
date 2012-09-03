$(document).ready -> 
  window.dialog = $('div#add-form').dialog(
    autoOpen: false
    modal: true
    width: '350px'
  )

  clearform = (form, type) ->
    form.find('table input').val('')
    form.find('table select').val('')
    $('#' + type + '_old_name', form).val('')

  $(document).on 'click', 'a[data-action="add"]', ->
    type = $(this).parent().data('type')
    form = $('div#add-form')
    clearform form, type
    $('div#add-form').dialog('open')

  $(document).on 'click', 'a[data-action="edit"]', ->
    type = $(this).parent().data('type')
    $row = $(this).parents('div.partial:first').find('table#add-destination .ui-state-hover:first').parent()
    return unless $row.length
    object = $row.data 'object'
    form = $('div#add-form')
    clearform form, type
    $('#' + type + '_old_name', form).val(object.name)
    for property, value of object
      $('#' + type + '_' + property, form).val(value)
    $('select#' + type + '_method').change()
    $('div#add-form').dialog('open')

  $(document).on 'click', 'a[data-action="delete"]', ->
    type = $(this).parent().data('type')
    $row = $('table#add-destination .ui-state-hover:first').parent()
    object = $row.data 'object'
    jQuery.ajax('/wizard/' + type + 's', 
      {
        type: 'DELETE', 
        data: ((t, o) -> d = {}; d[t] = o; d)(type, object)
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
       
