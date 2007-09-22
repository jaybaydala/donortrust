class DonortrustMailer < ActionMailer::Base
  HTTP_HOST = ENV['RAILS_ENV'] == 'development' ? 'dt.pivotib.com' : 'christmasfuture.org'
  
  def user_signup_notification(user)
    user_setup_email(user)
    subject  "#{@subject} ChristmasFuture Account Activation"
    body     :user => user, :url => url_for( :host => HTTP_HOST, :controller => 'dt/accounts', :action => 'activate', :id => user.activation_code )
  end

  def user_change_notification(user)
    user_setup_email(user)
    subject  "#{@subject} ChristmasFuture Account Email Confirmation"
    body :user => user, :host => HTTP_HOST, :url => url_for( :host => HTTP_HOST, :controller => 'dt/accounts', :action => 'activate', :id => user.activation_code )
  end
  
  def user_activation(user)
    user_setup_email(user)
    subject  "#{@subject} Your account has been activated!"
    body :user => user, :host => HTTP_HOST, :url => url_for( :host => HTTP_HOST, :controller => 'dt/accounts', :action => 'show', :id => user.id )
  end
  

  def gift_mail(gift)
    gift_setup_email(gift)
    subject 'You have received a ChristmasFuture Gift from ' + ( gift.name? ? gift.name : gift.email )
    headers "Reply-To" => gift.email
    body :gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")
    content_type 'multipart/alternative'
  end

  def gift_mail_preview(gift)
    gift_mail(gift)
    content_type 'text/html'
    body :gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")
    content_type 'text/html'
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
    @subject    = "Welcome to DonorTrust!"
    recipients  user.full_name ? "#{user.full_name}<#{user.email}>" : "#{user.email}"
    from        "The ChristmasFuture Team <info@christmasfuture.org>"
    sent_on     Time.now
  end

  def gift_setup_email(gift)
    content_type "text/html"
    recipients  gift.to_name ? "#{gift.to_name}<#{gift.to_email}>" : "#{gift.to_email}"
    from        "The ChristmasFuture Team <info@christmasfuture.org>"
    sent_on     Time.now
  end
end
