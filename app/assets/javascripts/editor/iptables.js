// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	
	var createEmptyInput = function (interfaceName, chainType) {
		return $('<input type="text" name="rules[' + interfaceName + '][' + chainType + '][]" />')
					.data('interface-type', interfaceName).data('chain-type', chainType);
	};
	
	var getLevelBoxList = function () {
		var rowContainer = this.parents('.level');
		return rowContainer.find('ul').not(this.parent()[0]);
	};
	
	var handler = {
		enter: function () {
			var $input = $(this);
			var $li = $input.parent();
			var $new = createEmptyInput($input.data('interface-type'), $input.data('chain-type'));
			$li.after($('<li></li>').html($new));
			$new.focus();
			var position = $li.index();
			getLevelBoxList.call($li).each(function () {
				$($(this).children()[position]).after(
					$('<li></li>').html(createEmptyInput($input.data('interface-type'), $(this).data('chain-type')))
				);
			});
			return false;
		},
		backspace: function () {
			var $input = $(this);
			if (!$input.val()) {
				var $li = $input.parent();
				$li.parent().append($li);
				getLevelBoxList.call($li).each(function () {
					
			});
			}		
		}
	}
	
	$(document).on('keydown', 'input[type="text"]', function(event) {
		switch(event.keyCode) {
			case 13: return handler.enter.call(this);
			case 8: return handler.backspace.call(this); 
		}
	})
	
	$('.interface').each(function() {
		var interfaceName = $(this).data('interface-type');
		
		$(this).find('ul').each(function() {
			var $ul = $(this), chainType = $ul.data('chain-type');
			var children = $(this).children()
			if (!children.length || children.last().text()) $(this).append('<li></li>')

			getLevelBoxList.call($ul).each(function () {
				var diff = $(this).children().length - $ul.children().length;
				if (0 < diff) {
					for (var i=0; i < diff; i++) {
						$ul.append('<li></li>');
					};
				}
			});
			
			$(this).find('li').each(function () {
				var $li = $(this);
				$li.html( createEmptyInput(interfaceName, chainType).val($li.text()));
			});
		});
	});
});