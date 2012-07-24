function bind_new_feedback_submit() {
  $('#new_feedback').bind('submit', function() {
    $('#spinner').show();
    $.post($(this).attr('action'), 
      $('#new_feedback').serialize(),
      function(data) {
        $('#spinner').hide();
        if (data.success) {
          $.colorbox({ opacity: 0.5, html: "<p>Thank you for your feedback.</p><p class='center'><a id='ok_btn' href='#'>Ok</a></p>", width: '300px' });
          $('#ok_btn').bind('click', function() { $.colorbox.close(); });
        } else {
          $("#new_feedback").replaceWith(data.html);
          bind_new_feedback_submit();
        }
      },
      'json'
    );
    return false;
  });
}

$(document).ready(function () {
  $('#feedback-badge').feedbackBadge({
    css3Safe: $.browser.safari ? true : false, // this trick prevents old safari browser versions from not scrolling properly
    float: 'right',
    onClick: function () {
      $('#feedback_form').show();
      $.colorbox({ inline: true, href: '#feedback_form', opacity: 0.5, width: '510px', height: '650px'});
    }
  });

  bind_new_feedback_submit();
});
