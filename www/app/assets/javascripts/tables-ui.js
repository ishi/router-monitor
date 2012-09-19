/* http://stackoverflow.com/questions/2613632/jquery-ui-themes-and-html-tables */
(function ($) {
  $.fn.styleTable = function (options) {
    var defaults = {
      css: 'ui-styled-table'
    };
    options = $.extend(defaults, options);

    return this.each(function () {
      var $this = $(this);
      $this.addClass(options.css);

      $this.on('mouseover mouseout', 'tbody tr', function (event) {
        if ($(this).data('selected-row')) return;
        $(this).children().toggleClass("ui-state-hover",
                                       event.type == 'mouseover');
      });

      $this.on('click', 'tbody tr', function () {
        var $parent = $(this).parent();
        $('td.ui-state-hover', $parent).removeClass('ui-state-hover');
        $('tr', $parent).data('selected-row', false);
        $(this).children().addClass('ui-state-hover');
        $(this).data('selected-row', !$(this).data('selected-row'));

        $($(this).data('disable-on-select')).button('disable').length
        $($(this).data('enable-on-select')).button('enable');
      });

      $this.find("th").addClass("ui-state-default");
      $this.find("td").addClass("ui-widget-content");
    });
  };
})(jQuery);
