$(document).ready -> 
  initializeDialog( $('div[data-crud-form]') )

  clearform = (form, type) ->
    to_clean = form.find('[data-crud-clean="true"]')
    to_clean.not('[type="checkbox"]').val("")
    to_clean.filter('[type="checkbox"]').prop('checked', false)

  $(document).on 'click', 'a[data-action="add"]', ->
    type = $(this).parent().data('type')
    form = $('div[data-crud-form~="add"]')
    clearform form, type
    form.dialog('open')

  $(document).on 'click', 'a[data-action="edit"]', ->
    type = $(this).parent().data('type')
    $row = $(this).parents('div.partial:first').find('table#add-destination .ui-state-hover:first').parent()
    return unless $row.length
    object = $row.data 'object'
    form = $('div[data-crud-form~="edit"]')
    clearform form, type
    $(form).trigger('crud:before-fill', object)
    for property, value of object
      input = $('[name="' + type + '\[' + property + '\]"]', form)
      if input.is('[type="checkbox"]')
        input.prop('checked', value)
        continue
      input.val(value)
    form.dialog('open')
    $(form).trigger('crud:after-fill', object)
    $('select', form).change()

  $(document).on 'click', 'a[data-action="delete"]', ->
    type = $(this).parent().data('type')
    $row = $('table#add-destination .ui-state-hover:first', $(this).parents('div.partial')).parent()
    object = $row.data 'object'
    jQuery.ajax('/wizard/' + type + 's', 
      {
        type: 'DELETE', 
        data: ((t, o) -> d = {}; d[t] = o; d)(type, object)
      })

  $(document).on 'change keyup', 'select#zone_method, select#zone_type', ->
    if $(this).val() == 'DHCP'
      $('input[data-disable-on*="method-dhcp"]').prop('readonly', true)
    else
      form = $(this).parents('div[data-crud-form]:first')
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
       
