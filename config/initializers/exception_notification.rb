ExceptionNotifier.exception_recipients = ['tim@tag.ca']
ExceptionNotifier.exception_recipients << 'info@uend.org' if Rails.env.production?
ExceptionNotifier.sender_address = %(support@uend.org)
ExceptionNotifier.email_prefix = "[DT #{Rails.env} ERROR] "
