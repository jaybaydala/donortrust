// remap jQuery to $
(function($){})(window.jQuery);

/* trigger when page is ready */
$(document).ready(function (){
  $("#project_search_tools select").change(function() {
    $(this).parent().submit();
  });
});


/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/