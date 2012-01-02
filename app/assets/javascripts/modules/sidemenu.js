$(function() {
	var methods = {
        init : function( options ) { 
            return this.each( function() {        
                // If options exist, lets merge them
                // with our default settings
                if ( options ) { 
                    $.extend( settings, options );
                }
                
                var $this = $(this);
                // ukrywamy menu
                methods.hide.apply(this);
                
                // gdy kliknięcie pokazujemy wybraną pozycję z menu
                $this.find('.menu-thumbnail,.menu-title').click(function() {
                	$this.find('.menu-items').hide();
					$this.find('.menu-spacer').hide();
					var $e = $(this).parents('.menu-entry');
					$this.find('.menu-title').show();
					$e.find('.menu-spacer').show();
					$e.find('.menu-items').show();
				})
				
				// jeśli myszka opuści opszar menu, chowamy je
                $this.mouseleave(function() {
					var $e = $(this);
					$e.find('.menu-title').hide();
					$e.find('.menu-items').hide();
					$e.find('.menu-spacer').hide();
				})
				
            })
        },
        // pokazujemy wszystko w menu
        show : function( ) {
        	var $e = $(this);
			$e.find('.menu-title').show();
			$e.find('.menu-items').show();
			$e.find('.menu-spacer').show();
        },
        // ukrywamy wszystko w menu
        hide : function( ) {
			var $e = $(this);
			$e.find('.menu-title').hide();
			$e.find('.menu-items').hide();
			$e.find('.menu-spacer').hide();
        },
    };
	
	$.fn.sideMenu = function( method ) {
		
        // Method calling logic
        if ( methods[method] ) {
            return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on jQuery.sideMenu' );
        }
		
		
    };
});