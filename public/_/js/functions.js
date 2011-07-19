// remap jQuery to $
(function($){})(window.jQuery);

/* trigger when page is ready */
$(document).ready(function (){
  $("#project_search_tools select").change(function() {
    $(this).parent().submit();
  });
  if ($('#project-carousel').length > 0) {
    $("#project-carousel").cycle({ pause:1, width:$("#project-carousel").width()+'px' });
  }

  $('#e_card-selection img').click(function() {
    $('#e_card-preview img').attr("src", $(this).attr("data_url"));
    $("#gift_e_card_id").attr("value", $(this).attr("data_id"));
  });
  $("#gift_preview").click(function() {
    var form = $(this).closest("form");
    window.open($(this).attr("href") + '?' + $(form).serialize(), "giftpreview", 'width=600,height=450,location=0')
    return false;
  });
});

/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/