function bind_new_feedback_submit() {
  $('#new_feedback').bind('submit', function() {
    $('#spinner').show();
    $.post($(this).attr('action'), 
      $('#new_feedback').serialize(),
      function(data) {
        $('#spinner').hide();
        if (data.success) {
          $.colorbox({ opacity: 0.5, html: "<P>Thank you for your feedback.</P><P class='center'><A href='#', onClick='$.colorbox.close()'>Ok</A></div</P>" });
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
      $.colorbox({ inline: true, href: '#feedback_form', opacity: 0.5, width: '510px', height: '530px'});
    }
  });

  bind_new_feedback_submit();
});
