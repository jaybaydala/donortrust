class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'ChristmasFuture Account Activation'
    @body[:url]  = "http://www.christmasfuture.org/dt/accounts;activate?id=#{user.activation_code}"
  end

  def change_notification(user)
    setup_email(user)
    @subject    += 'ChristmasFuture Account Email Confirmation'
    @body[:url]  = "http://www.christmasfuture.org/dt/accounts;activate?id=#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://www.christmasfuture.org/"
  end
  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "info@christmasfuture.org"
    @subject     = "Welcome to DonorTrust! "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
