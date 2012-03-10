$(function() {
	// tworzymy przyciski na stronie
	$('.button').button();
	// tworzymy menu po lewej
	$('#menu').sideMenu();
	// chowamy komunikaty
	var intervalStep = 5000, hideInterval = intervalStep;
	$('.ui-message').each(function() {
		$(this).click(function() { $(this).clearQueue().fadeOut(); })
				.delay(hideInterval).fadeOut();
		hideInterval += intervalStep;
	})
});
