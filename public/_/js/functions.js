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
  $("#gift_preview").click(function(event) {
    event.preventDefault();
    var form = $(this).closest("form");
    if ($("#dialog").length == 0) {
      // $('body').append($('<div id="dialog-overlay">').addClass('ui-widget-overlay').hide());
      $('body').append($('<div id="dialog">').append('<iframe>').hide());
    }
    var href = $(this).attr("href") + '?' + $(form).serialize();
    $('#dialog iframe').attr('src', href);
    $("#dialog").dialog({ 
      width:600, 
      height:450, 
      title:'Ecard Preview',
      modal: true//,
      // open: function(event, ui) { $('#dialog-overlay').show() },
      // close: function(event, ui) { $('#dialog-overlay').hide() }
    });
    
    // window.open($(this).attr("href") + '?' + $(form).serialize(), "giftpreview", 'width=600,height=450,location=0')
  });
});

/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/