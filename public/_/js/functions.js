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
    $("#share_e_card_id").attr("value", $(this).attr("data_id"));
  });
  // $("#gift_preview").click(function(event) {
  //   event.preventDefault();
  //   var form = $(this).closest("form");
  //   if ($("#dialog").length == 0) {
  //     $('body').append($('<div id="dialog">').append('<iframe>').hide());
  //   }
  //   var href = $(this).attr("href") + '?' + $(form).serialize();
  //   $('#dialog iframe').attr('src', href);
  //   $("#dialog").dialog({
  //     width:600,
  //     height:450,
  //     dialogClass: 'remove_header_class',
  //     open: function() { $(".remove_header_class .ui-widget-header").removeClass("ui-widget-header"); },
  //     modal: true
  //   });
  // });
  $("#gift_preview").colorbox({
    iframe: true,
    height: 550,
    width: 620,
    href: function() {
      return $(this).attr("href") + '?' + $(":input[id!='gift_to_emails']", $("#gift_preview").closest("form")).serialize();
    }
  });

  // login link
  $("#loginlink").colorbox();

  // donation form
  if ($('#cart_line_item_percentage').val() != '') $('#cart_line_item_amount').hide();
  $("#cart_line_item_percentage").change(function() {
    if ($(this).val() == '') {
      $("#cart_line_item_amount").show();
    } else {
      $("#cart_line_item_amount").hide();
    }
  });

  // form submit replacements - big buttons
  $("#investmentform, #paymentform, #billingform, #signupform, #userform, #upoweredform, #tellfriendform, form.upowered_share, form.newsletter_signups").each(function() {
    var form = $(this);
    var submit = $('input[type=submit]', $(this));
    var button = $("<a>").addClass('bigbutton').click(function() { form.submit() }).html(submit.attr('value'));
    submit.before(button).hide();
  });
  // form submit replacements - small buttons
  $("#loginform, #facebook_post, #giftpickupform").each(function() {
    var form = $(this);
    var submit = $('input[type=submit]', $(this));
    var button = $("<a>").addClass('smallbutton').click(function() { form.submit() }).html(submit.attr('value'));
    submit.before(button).hide();
  });

  // center the #sectionnav
  $("#sectionnav").each(function() {
    $(this).css('left', $(this).parent().width()/2-$(this).width()/2 );
  });

  // checkout
  if ($.fn.calculate_payment_required) {
    $("#payment_options").calculate_payment_required({ total_field: '#order_total' });
  }

  // newsletter signup
  $('a.newsletter_signup_link, a.colorbox').colorbox();

  // simple autogrow
  if ($.fn.autoGrow) {
    $('textarea.autogrow').autoGrow();
  }

  // FB Invite Friends
  $("#fb-invite_friends").click(function() { sendRequestViaMultiFriendSelector(); });

  /* When I set the background image using layout.css for impact-tab-me by default, then
  * resetting the css background with css("background", "") didn't work. */
  $("#impact-tab-me").css("background", "url('/images/iend/impact-tab_bg-green.png')");

  $(".impact-tab").click(function() {
    $(".impact-tab").css("background", "");
    $(this).css("background", "url('/images/iend/impact-tab_bg-green.png')");
    $(".profile-stats").hide();
    stats_for = $(this).attr('id').split("-").pop(); // will be either 'me', 'friends', or 'uend'
    $("#impact-stats-"+stats_for).show();
  });
  // Account Edit individual/group radio button events
  account_name_display($('#user_group_input input[type=radio]:checked').attr('id'));
  $('#user_group_input input[type=radio]').change(function(){
    account_name_display($(this).attr('id'));
  });

});

// Update Account Edit name fields depending on individual or group selection
// radio_id is either user_group_true or user_group_false
function account_name_display(radio_id){
  if(radio_id == 'user_group_true'){
    $('#user_last_name_input').hide();
    $('#user_first_name_input label').html('Group name');
    $('#user_last_name').val('');
  }
  else{
    $('#user_last_name_input').show();
    $('#user_first_name_input label').html('First name');
  }
  // alert(radio_id);
}

/* optional triggers
$(window).load(function() {
});

$(window).resize(function() {
});
*/
