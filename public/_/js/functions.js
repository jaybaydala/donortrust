// remap jQuery to $
(function($){})(window.jQuery);

/* trigger when page is ready */
$(document).ready(function (){
  // project search
  $("#project_search_tools select").change(function() {
    $(this).parent().submit();
  });

  // project page
  if ($('#project-carousel').length > 0) {
    $("#project-carousel").cycle({ pause:1, width:$("#project-carousel").width()+'px' });
  }

  // gift form
  $('#e_card-selection img').click(function() {
    $('#e_card-preview img').attr("src", $(this).attr("data_url"));
    $("#gift_e_card_id").attr("value", $(this).attr("data_id"));
  });
  $("#gift_preview").click(function(event) {
    event.preventDefault();
    var form = $(this).closest("form");
    if ($("#dialog").length == 0) {
      $('body').append($('<div id="dialog">').append('<iframe>').hide());
    }
    var href = $(this).attr("href") + '?' + $(form).serialize();
    $('#dialog iframe').attr('src', href);
    $("#dialog").dialog({ 
      width:600, 
      height:450, 
      dialogClass: 'remove_header_class',
      open: function() { $(".remove_header_class .ui-widget-header").removeClass("ui-widget-header"); },
      modal: true
    });
  });
  
  // donation form
  if ($('#cart_line_item_percentage').val() != '') $('#cart_line_item_amount').hide();
  $("#cart_line_item_percentage").change(function() {
    if ($(this).val() == '') {
      $("#cart_line_item_amount").show();
    } else {
      $("#cart_line_item_amount").hide();
    }
  });
});

/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/