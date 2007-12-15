module EmailParser
  protected
  def emails(email_list)
    emails = email_list.class == String ? email_list.split(%r{,\s*}) : email_list
    emails.collect! { |email| email.strip }
    emails
  end
end