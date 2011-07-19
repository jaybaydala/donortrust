(function($){
  $.fn.formnav = function( options ) {
    var settings = {
      'fieldset_selector'  : '>fieldset.inputs',
      'button_fieldset_selector' : '>fieldset.buttons',
      'submit_selector' : '.buttons input[type=submit]'
    };

    var build_nav_elements = function(form, current_fieldset) {
      var fieldsets = $(settings['fieldset_selector'], $(form));
      var titles = $.map(fieldsets, function(fieldset) {
        return $('legend', fieldset).text();
      });
      var list = $('<ul>');
      $.each(titles, function(i, title) {
        var li = $('<li>').addClass("span-2").text(title);
        if (current_fieldset && $('legend', current_fieldset).text() == title) {
          li.addClass("current");
        }
        list.append(li);
      });
      list.append($('<li>').addClass("span-2").text('Cart'));
      $('#formnav').remove();
      $(form).before($('<nav>').addClass('clearfix').attr('id', 'formnav').append(list));
    }

    return this.each(function() {
      if (options) { $.extend(settings, options); }
      $(settings['fieldset_selector'], $(this)).hide().first().show();
      $(settings['button_fieldset_selector'], $(this)).hide();
      $(settings['fieldset_selector'], $(this)).each(function() {
        var current = $(this);
        var form = current.parent("form");
        var next = (current.next('.inputs').length > 0) ? $("<a>").addClass('bigbutton').click(function() { build_nav_elements(form, current.next('.inputs')); current.hide(); current.next('.inputs').show(); }).html("next") : false ;
        var prev = (current.prev('.inputs').length > 0) ? $("<a>").addClass('bigbutton').addClass('black').click(function() { build_nav_elements(form, current.prev('.inputs')); current.hide(); current.prev('.inputs').show(); }).html("previous") : false ;
        button_container = $("<div>").addClass("buttons").addClass("clearfix");
        if (prev) { button_container.append(prev); }
        if (next) {
          button_container.append(next);
        } else {
          submit = $(settings['submit_selector'], current.parent());
          button_container.append($("<a>").addClass('bigbutton').click(function() { current.parent("form").submit(); }).html(submit.attr('value')));
        }
        current.append(button_container);
      });
      build_nav_elements($(this), $(settings['fieldset_selector'], $(this)).first());
    });
  };
})(jQuery);
