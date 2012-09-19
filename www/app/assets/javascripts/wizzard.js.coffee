$( ->
  # zakładki
  $('.wizard div#tabs').tabs({
    disabled: [1,2],
    load: (event, ui) -> 
      repeatableInitialization(ui.panel)
  })

  $(document).on 'click', '.wizard div#tabs .button[data-action="next"]', -> 
    tabs = $(this).parents('div#tabs:first')
    selected = tabs.tabs( "option", "selected" )
    tabs.tabs('enable', selected + 1).tabs('select', selected + 1)
  $(document).on 'click', '.wizard div#tabs .button[data-action="prev"]', -> 
    tabs = $(this).parents('div#tabs:first')
    tabs.tabs('select', tabs.tabs( "option", "selected" ) - 1)
)
