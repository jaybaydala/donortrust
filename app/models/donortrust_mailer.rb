require 'pdf_factory'
class DonortrustMailer < ActionMailer::Base
  include PDFProxy
  HTTP_HOST = 'www.christmasfuture.org'
  
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
    headers "Reply-To" => gift.name? ? "#{gift.name} <#{gift.email}>" : gift.email
    body_data = {:gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")}
    part :content_type => "text/html", 
      :body => render_message('gift_mail.text.html.rhtml', body_data)

    attachment "application/pdf" do |a|
      proxy = create_pdf_proxy(gift)
      a.filename= proxy.filename
      a.body = proxy.render
    end
  end

  def gift_mail_preview(gift)
    gift_mail(gift)
    content_type 'text/html'
    #body :gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")
    #content_type 'text/html'
  end

  def gift_open(gift)
    gift_setup_email(gift)
    recipients "#{gift.email}"
    subject "Your gift to #{gift.to_name} has been opened!"
    attachment "application/pdf" do |a|
      proxy = PDFProxy.create_pdf_proxy(gift)
      a.filename= proxy.filename
      a.body = proxy.render
    end
  end

  def gift_remind(gift)
    gift_setup_email(gift)
    subject 'GiftNotifier#gift'
    content_type 'text/plain'
    headers {}
  end

  def tax_receipt(receipt)
    content_type "text/html"
    recipients  "#{receipt.first_name} #{receipt.last_name} <#{receipt.user.email}>"
    from        "The ChristmasFuture Team <info@christmasfuture.org>"
    sent_on     Time.now
    subject "Tax receipt for your gift"
    body "Thank you for your gift, please find your attached tax receipt"
    attachment "application/pdf" do |a|
      # switched to a proxy pattern (encryption requires a lot of shenanigans)
      proxy = create_pdf_proxy(receipt)
      a.body = proxy.render(duplicate=false)
      a.filename = proxy.filename
      proxy.post_render # this removes the tmp files needed to encrypt
    end
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
