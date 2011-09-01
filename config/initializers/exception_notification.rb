ExceptionNotifier.exception_recipients = ['tim@tag.ca']
ExceptionNotifier.exception_recipients << 'info@uend.org' if Rails.env.production?
ExceptionNotifier.sender_address = %(support@christmasfuture.com)
ExceptionNotifier.email_prefix = "[DT ERROR] "
