class UpoweredMailer < ActionMailer::Base
  def upowered_share(from_name, from_email, to_email, message)
    content_type "text/plain"
    subject "Join me in ending poverty"
    from "#{from_name} - via UEnd:Poverty <info@uend.org>"
    recipients to_email
    reply_to from_email
    sent_on Time.now
    body message
  end

end