$(document).ready -> 
  clearform = (form) ->
    form.find('table input').val('')
    form.find('table select').val('')
  

  $(document).on 'change keyup', 'div#crud-form-interface select#type', ->
    $('div.interface-form').hide()
    return if not $(this).val()
    form = $('div#interface-form-' + $(this).val().toLowerCase())
    clearform form
    form.show()
