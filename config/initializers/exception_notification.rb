ExceptionNotifier.exception_recipients = []
ExceptionNotifier.exception_recipients << 'tim@tag.ca' unless Rails.env.production?
ExceptionNotifier.exception_recipients << 'info@uend.org' if Rails.env.production?
ExceptionNotifier.sender_address = %(support@uend.org)
ExceptionNotifier.email_prefix = "[DT #{Rails.env} ERROR] "
