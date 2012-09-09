$(document).ready -> 
  $(document).on 'change keyup', 'div#crud-form-interface select#type', ->
    $('div.interface-form').hide()
    return if not $(this).val()
    form = $('div#interface-form-' + $(this).val().toLowerCase()).show()


  $(document).on 'crud:after-fill', 'div#crud-form-interface', (event, object) ->
    $('select#type', this).val(object.type)
