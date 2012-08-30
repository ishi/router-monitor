$(function() {
  var repeatableInitialization = function ( context ) {
    // tworzymy przyciski na stronie
    $('.button', context).button();
    // style dla tabelek
    $("table.grid", context).styleTable();
    if (window.dialog) window.dialog.remove();
    window.dialog = $('div#add-form').dialog({
      autoOpen: false,
      modal: true,
      width: '350px'
    });

  }
	// tworzymy menu po lewej
	$('#menu').sideMenu();
	// chowamy komunikaty
	var intervalStep = 5000, hideInterval = intervalStep;
	$('.ui-message').each(function() {
		$(this).click(function() { $(this).clearQueue().fadeOut(); })
				.delay(hideInterval).fadeOut();
		hideInterval += intervalStep;
	})
  
  // zakładki
  $("div#tabs").tabs({
    load: function(event, ui) { repeatableInitialization(ui.panel); }
  });
  repeatableInitialization(document);
});
