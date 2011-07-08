// remap jQuery to $
(function($){})(window.jQuery);

/* trigger when page is ready */
$(document).ready(function (){
  $("#project_search_tools select").change(function() {
    $(this).parent().submit();
  });
  $("#project-carousel").cycle({ pause:1, width:$("#project-carousel").width()+'px' });
  console.log($("#project-carousel").height());
});


/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/