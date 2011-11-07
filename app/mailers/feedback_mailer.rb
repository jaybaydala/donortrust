class FeedbackMailer < ActionMailer::Base
  HTTP_HOST = (['staging', 'production'].include?(ENV['RAILS_ENV']) ? 'www.uend.org' : 'localhost:3000') if !const_defined?('HTTP_HOST')

  def feedback(name, email, subject, message, created_at)
    from email
    subject "Feedback: #{subject}"
    recipients "info@uend.org"
    body :host => HTTP_HOST, :name => name, :email => email, :message => message, :created_at => created_at
  end
end

# Mailer methods have the following configuration methods available.
# 
#     * recipients - Takes one or more email addresses. These addresses are where your email will be delivered to. Sets the To: header.
#     * subject - The subject of your email. Sets the Subject: header.
#     * from - Who the email you are sending is from. Sets the From: header.
#     * cc - Takes one or more email addresses. These addresses will receive a carbon copy of your email. Sets the Cc: header.
#     * bcc - Takes one or more email addresses. These addresses will receive a blind carbon copy of your email. Sets the Bcc: header.
#     * reply_to - Takes one or more email addresses. These addresses will be listed as the default recipients when replying to your email. Sets the Reply-To: header.
#     * sent_on - The date on which the message was sent. If not set, the header wil be set by the delivery agent.
#     * content_type - Specify the content type of the message. Defaults to text/plain.
#     * headers - Specify additional headers to be set for the message, e.g. headers ‘X-Mail-Count’ => 107370.
