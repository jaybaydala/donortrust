(function($){
  $.fn.formnav = function( options ) {
    var settings = {
      'fieldset_selector'  : '>fieldset.inputs',
      'button_fieldset_selector' : '>fieldset.buttons',
      'submit_selector' : '.buttons input[type=submit]'
    };

    return this.each(function() {
      if (options) { $.extend(settings, options); }
      var current_index = (document.location.hash != '') ? document.location.hash.replace(/^#formnav-/,'') : 0 ;
      var current = $(settings['fieldset_selector'], $(this))[current_index];
      var form = $(this);

      var build_nav_elements = function() {
        var fieldsets = $(settings['fieldset_selector'], $(form));
        var titles = $.map(fieldsets, function(fieldset) {
          return $('legend', fieldset).text();
        });
        var list = $('<ul>');
        $.each(titles, function(i, title) {
          var li = $('<li>').attr('id', 'formnav-' + i).addClass("span-2").text(title);
          if (current && $('legend', current).text() == title) {
            li.addClass("current");
            if (i > 0) document.location.hash = 'formnav-'+i;
            else document.location.hash = '';
          }
          list.append(li);
        });
        list.append($('<li>').addClass("span-2").text('Cart'));
        $('#formnav').remove();
        $(form).before($('<nav>').addClass('clearfix').attr('id', 'formnav').append(list));
      }

      var next = function() {
        $(current).hide();
        current = $($(current).next('.inputs'));
        current_index += 1;
        document.location.hash = 'formnav-' + current_index;
        $(current).show();
      }

      var prev = function() {
        $(current).hide();
        current = $($(current).prev('.inputs'));
        current_index -= 1;
        document.location.hash = 'formnav-' + current_index;
        $(current).show();
      }

      var button = function(text, callback, black) {
        var thebutton = $("<a>").addClass('bigbutton').text(text).click(callback);
        if (black) thebutton.addClass("black");
        return thebutton;
      }

      var append_buttons = function(fieldset) {
        var next_button = (fieldset.next('.inputs').length > 0) ? button('next', function(){next()}, false) : false ;
        var prev_button = (fieldset.prev('.inputs').length > 0) ? button('previous', function(){prev()}, true) : false ;
        button_container = $("<div>").addClass("buttons").addClass("clearfix");
        if (prev_button) { button_container.append(prev_button); }
        if (next_button) {
          button_container.append(next_button);
        } else {
          submit = $(settings['submit_selector'], fieldset.parent());
          button_container.append($("<a>").addClass('bigbutton').click(function() { fieldset.parent("form").submit(); }).html(submit.attr('value')));
        }
        fieldset.append(button_container);
      }

      $(settings['fieldset_selector'], $(this)).hide();
      $(current).show();
      $(settings['button_fieldset_selector'], $(this)).hide();
      $(settings['fieldset_selector'], $(this)).each(function(i) {
        append_buttons($(this));
      });
      build_nav_elements();
      
      $(window).hashchange( function(){
        var hash = location.hash;
        current_index = hash ? hash.replace(/^#formnav-/, '') : 0 ;
        var current = $(settings['fieldset_selector'], $(this))[current_index]
        build_nav_elements($(this), $(current))
        $(window).hashchange();
      });
      
    });
  };
})(jQuery);
