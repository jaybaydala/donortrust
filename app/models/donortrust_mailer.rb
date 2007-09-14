class DonortrustMailer < ActionMailer::Base
  HTTP_HOST = ENV['RAILS_ENV'] == 'development' ? 'localhost' : 'dt.pivotib.com'
  
  def user_signup_notification(user)
    user_setup_email(user)
    @subject    += 'ChristmasFuture Account Activation'
    @body[:url]  = "http://#{HTTP_HOST}/dt/accounts;activate?id=#{user.activation_code}"
  end

  def user_change_notification(user)
    user_setup_email(user)
    @subject    += 'ChristmasFuture Account Email Confirmation'
    @body[:url]  = "http://#{HTTP_HOST}/dt/accounts;activate?id=#{user.activation_code}"
  end
  
  def user_activation(user)
    user_setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{HTTP_HOST}/"
  end
  

  def gift_mail(gift)
    gift_setup_email(gift)
    subject 'You have received a ChristmasFuture Gift from ' + ( gift.name != nil ? gift.name : gift.email )
    headers "Reply-To" => gift.email
    body :gift => gift, :url => url_for(:host => "www.christmasfuture.org", :controller => "dt/gifts", :action => "open")
  end

  def gift_open(gift)
    gift_setup_email(gift)
    recipients "#{gift.email}"
    subject "Your gift to #{gift.to_name} has been opened!"
    headers {}
  end

  def gift_remind(gift)
    gift_setup_email(gift)
    subject 'GiftNotifier#gift'
    headers {}
  end

  protected
  def user_setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "info@christmasfuture.org"
    @subject     = "Welcome to DonorTrust! "
    @sent_on     = Time.now
    @body[:user] = user
  end

  def gift_setup_email(gift)
    recipients "#{gift.to_email}"
    from "info@christmasfuture.org"
    sent_on Time.now
  end
end
