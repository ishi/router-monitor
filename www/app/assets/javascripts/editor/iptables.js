// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
	
	var createEmptyInput = function (interfaceName, chainType) {
		return $('<div name="rules[' + interfaceName + '][' + chainType + '][]" contenteditable="true"/>')
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
      var next = $li.next().children('[contenteditable]:first')
      if (next.length && next.val().trim() == '') {
        next.focus()
        return false;
      }
			var $new = createEmptyInput($input.data('interface-type'), $input.data('chain-type'));
			$li.after($('<li></li>').html($new));
			$new.focus();
			var position = $li.index();
			getLevelBoxList.call($li).each(function () {
				
				var $newInput = $('<li></li>').html(
					createEmptyInput($input.data('interface-type'), $(this).data('chain-type')))
				$($(this).children()[position]).after($newInput);
			});
			return false;
		},
		backspace: function (event) {
			var $input = $(this);
      event.isImmediatePropagationStopped();
			if (!$input.text()) {
				var $li = $input.parent(),
					$ul = $li.parent();
					$prev = $li.prev();
				var remove = true;
				var thisSize = 0;
				if ($ul.find('div[contenteditable]').length < 2) {
					remove = false;
				} else {
					$ul.find('div[contenteditable]').each(function () {
						if ($(this).text()) {
							thisSize++;
						}
					})
					getLevelBoxList.call($li).each(function () {
						var size = 0
						$(this).find('div[contenteditable]').each(function () {
							if ($(this).text()) {
								size++;
							}
						})
						if(thisSize < size) {
							remove = false;
						}	
					});
				}
				if (remove) {
					getLevelBoxList.call($li).children().last().remove();
					$li.remove();
				} else {
					$li.parent().append($li);
				}
				$prev.children().first().focus();
			}
		}
	}
	
	$(document).on('keydown', 'div[contenteditable]', function(event) {
		switch(event.keyCode) {
			case 13: return handler.enter.call(this, event);
			case 8: return handler.backspace.call(this, event); 
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
				var $li = $(this),
					$input = createEmptyInput(interfaceName, chainType).html($li.text())
				$li.html($input);
			});
		});
	});

	$('#iptables-editor-form').on('submit', function () {
		$(this).find('div[contenteditable]').each(function () {
			var input = $('<input type="hidden" />');
			input.attr('name', $(this).attr('name'));
			input.val($(this).text());
			$(this).before(input);
		})
	});
});
