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

  // if ($('#giftform').length > 0) {
  //   $('#giftform>fieldset.inputs').hide();
  // }
});


/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/