require 'pdf_proxy'

class DonortrustMailer < ActionMailer::Base
  #unloadable
  include PDFProxy
  if !const_defined?('HTTP_HOST')
    HTTP_HOST = if Rails.env.staging?
      'staging.uend.org'
    elsif Rails.env.production?
      'www.uend.org'
    else
      'localhost:3000'
    end
  end

  #MP - Dec. 14, 2007
  #Added to support US donations
  #When an administrator inputs a deposit on behalf of a user
  #whose original deposit went through GroundSpring, this email
  #is sent so that the user is aware that their deposit has been
  #put into their Christmas Future account.
  def us_deposit_notification(user)
    user_setup_email(user)
    subject "Your donation has been processed."
    body :user => user, :host => HTTP_HOST, :url => login_url(:host => HTTP_HOST)
  end
  
  def user_signup_notification(user)
    user_setup_email(user)
    subject  "The future is here."
    body     :user => user, :url => url_for( :host => HTTP_HOST, :controller => 'dt/accounts', :action => 'activate', :id => user.activation_code )
  end

  def user_change_notification(user)
    user_setup_email(user)
    subject  "#{@subject} UEnd: Account Email Confirmation"
    body :user => user, :host => HTTP_HOST, :url => url_for( :host => HTTP_HOST, :controller => 'dt/accounts', :action => 'activate', :id => user.activation_code )
  end
  
  def user_activation(user)
    user_setup_email(user)
    subject  "#{@subject} Your account has been activated!"
    body :user => user, :host => HTTP_HOST, :url => url_for( :host => HTTP_HOST, :controller => 'dt/accounts', :action => 'show', :id => user.id )
  end

  def user_password_reset(user)
    user_setup_email(user)
    subject  "Your UEnd: password has been reset"
    body :user => user, :host => HTTP_HOST, :url => login_url(:host => HTTP_HOST)
  end

  def account_expiry_reminder(user)
    user_setup_email(user)
    subject  "Your UEnd: account"
    body :user => user, :host => HTTP_HOST, :url => dt_projects_url(:host => HTTP_HOST)
  end

  def account_expiry_processed(user)
    recipients  "info@uend.org,tim@tag.ca"
    from        "info@uend.org"
    sent_on     Time.now
    subject  "Expired UEnd: account"
    body :user => user, :host => HTTP_HOST, :url => dt_projects_url(:host => HTTP_HOST)
  end
  
  def wishlist_mail(share, project_ids)
    content_type "text/html"
    recipients  share.to_name ? "\"#{share.to_name}\" <#{share.to_email}>" : "#{share.to_email}"
    from        "\"#{share.name} via UEnd\" <info@uend.org>"
    sent_on     Time.now
    subject     'Your friend wanted you to see their UEnd: Wishlist.'
    headers     "Reply-To" => share.name? ? "\"#{share.name}\" <#{share.email}>" : share.email
    url = share.project_id? ? dt_project_path(share.project) : dt_projects_path
    projects = Project.find(project_ids)
    body_data = {:share => share, :host => HTTP_HOST, :url => url, :projects => projects}
    content_type "text/html"
    body render_message('wishlist_mail.text.html.rhtml', body_data)
  end
  
  def invitation_mail(invitation)
    content_type "text/html"
    recipients  invitation.to_name ? "\"#{invitation.to_name}\" <#{invitation.to_email}>" : "#{invitation.to_email}"
    from        "\"#{invitation.user.full_name} via UEnd\" <#{invitation.user.email}>"
    sent_on     Time.now
    subject     "You have been invited to join the \"#{invitation.group.name}\" group at Uend"
    url = dt_group_url(:host => HTTP_HOST, :id => invitation.group_id)
    body_data = {:invitation => invitation, :host => HTTP_HOST, :url => url}
    content_type "text/html"
    body render_message('invitation_mail.text.html.rhtml', body_data)
  end

  def share_mail(share)
    content_type "text/html"
    recipients  share.to_name ? "\"#{share.to_name}\" <#{share.to_email}>" : "#{share.to_email}"
    from        "\"#{share.user.full_name} via UEnd\" <info@uend.org>"
    sent_on     Time.now
    subject     'Your friend thought you would like this.'
    headers     "Reply-To" => share.name? ? "\"#{share.name}\" <#{share.email}>" : share.email
    url = share.project_id? ? dt_project_path(share.project) : dt_projects_path
    body_data = {:share => share, :host => HTTP_HOST, :url => url}
    content_type "text/html"
    body render_message('share_mail.text.html.rhtml', body_data)
  end

  def gift_mail(gift)
    gift_setup_email(gift)
    subject 'You have been gifted!'
    headers "Reply-To" => gift.name? ? "\"#{gift.name}\" <#{gift.email}>" : gift.email
    body_data = {:gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")}
    content_type "text/html"
    body render_message('gift_mail.text.html.rhtml', body_data)
  end

  def gift_confirm(gift)
    content_type "text/html"
    recipients  "\"#{gift.first_name} #{gift.last_name}\" <#{gift.email}>"
    from        "\"#{gift.name} via UEnd\" <info@uend.org>"
    sent_on     Time.now
    subject "Your gift has been created and is ready for opening"
    amount = number_to_currency(gift.amount)
    body "<p>Thanks kind gifter! With your generous gift of #{amount}, we're one gift closer to changing the world...for good. </p><p>Please find your attached gift card</p><p>You can also download your printable ecard here:<br />#{dt_gift_url(:id => gift.id, :host => HTTP_HOST)}.pdf?code=#{gift.pickup_code}</p><p>All the best to you this holiday season,<br />The UEnd: Team</p>"
    attachment "application/pdf" do |a|
      # switched to a proxy pattern (encryption requires a lot of shenanigans)
      proxy = create_pdf_proxy(gift)
      a.body = proxy.render
      a.filename = proxy.filename
    end
  end

  def gift_notify(gift)
    recipients  "\"#{gift.first_name} #{gift.last_name}\" <#{gift.email}>"
    from        "\"#{gift.name} via UEnd\" <info@uend.org>"
    sent_on     Time.now
    subject "Your UEnd: gift has been opened"
    content_type "text/html"
    amount = number_to_currency(gift.amount)
    body "<p>The gift you gave to #{gift.to_name} &lt;#{gift.to_email}&gt; has been opened! With your generous gift of #{amount}, we're one gift closer to changing the world...for good. </p><p>All the best to you this holiday season,<br />The UEnd: Team</p>"
  end
  
  def gift_request(requestee_profile, requester)
    recipients  "\"#{requestee_profile.user.first_name} #{requestee_profile.user.last_name}\" <#{requestee_profile.user.email}>"
    from        "\"#{requester.first_name} #{requester.last_name}\" <#{requester.email}>"
    sent_on     Time.now
    content_type "text/html"
    subject "What I Really Want..."
    body "<p>Hi.</p><p>In case you were wondering what I wanted for a gift, I thought I'd let you know... a UEnd gift card! That way we can still do the 'gift' thing and we can both feel awesome... AND we make others feel awesome as well! I get to put the funds towards a poverty-ending project of my choice. What an incredible gift that would be.</p><p>Thank you! Just go to <a href=\"http://www.uend.org/dt/\">www.uend.org</a> and click GIVE.</p>"
  end

  def new_place_notify(place)
    recipients  "info@uend.org"
    from        "info@uend.org"
    sent_on     Time.now
    subject 	"A new place has been created"
    body 	"The new place #{place.name} was created in the country #{place.country.name}. Please approve or delete it."
  end

 def gift_resendPDF(gift)
    content_type "text/html"
    recipients  "\"#{gift.first_name} #{gift.last_name}\" <#{gift.email}>"
    from        "\"#{gift.name} via UEnd\" <info@uend.org>"
    sent_on     Time.now
    subject "Resolved Problem viewing Gift Card"
    body "<p>We have resolved a problem with the ability to view the PDF gift cards that were attached to your gift confirmation.  Please find attached the gift card for your gift to #{ gift.to_name }  </p><p>All the best to you this holiday season,<br />The UEnd: Team</p>"
    attachment "application/pdf" do |a|
      # switched to a proxy pattern (encryption requires a lot of shenanigans)
      proxy = create_pdf_proxy(gift)
      a.body = proxy.render
      a.filename = proxy.filename
    end
  end

  def gift_resend_sender(gift)
    content_type "text/html"
    recipients  "\"#{gift.first_name} #{gift.last_name}\" <#{gift.email}>"
    from        "info@uend.org"
    sent_on     Time.now
    subject 'Resent: You have been gifted!'
    body_data = {:gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")}
    body render_message('gift_resend_sender.html.erb', body_data)
  end

  def gift_expiry_notifier(gift)
    recipients  gift.name? ? "\"#{gift.name}\" <#{gift.email}>" : "#{gift.email}"
    from        "\"#{gift.name} via UEnd\" <info@uend.org>"
    sent_on Time.now
    subject 'You gave a UEnd: gift that hasn\'t been opened!'
    headers "Reply-To" => gift.to_name? ? "\"#{gift.to_name}\" <#{gift.to_email}>" : gift.to_email
    body_data = {:gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")}
    content_type "text/html"
    body render_message('gift_late_notifier.text.html.rhtml', body_data)
  end

  def gift_expiry_reminder(gift)
    gift_setup_email(gift)
    subject 'You have been gifted! This is a reminder'
    headers "Reply-To" => gift.name? ? "\"#{gift.name}\" <#{gift.email}>" : gift.email
    body_data = {:gift => gift, :host => HTTP_HOST, :url => url_for(:host => HTTP_HOST, :controller => "dt/gifts", :action => "open")}
    content_type "text/html"
    body render_message('gift_remind.text.html.rhtml', body_data)
  end
  
  def upowered_email_subscription(email_subscription)
    from "upowered@uend.org"
    recipients email_subscription.email
    subject 'U:Powered campaign updates'
    sent_on Time.now
    body[:unsubscribe_url] = unsubscribe_dt_upowered_email_subscribe_url(email_subscription.code, :host => HTTP_HOST)
    body[:upowered_url] = dt_upowered_url(:host => HTTP_HOST)
    body[:subscription] = email_subscription
  end

  def subscription_thanks(subscription)
    from "upowered@uend.org"
    recipients subscription.email
    subject 'UPowered: Thank you!'
    sent_on Time.now
    body[:subscription] = subscription
  end

  def subscription_failure(subscription)
    from "upowered@uend.org"
    recipients subscription.email
    subject 'UPowered: Subscription Problem'
    sent_on Time.now
    body[:subscription] = subscription
    body[:edit_upowered_url] = edit_iend_subscription_url(subscription, :host => HTTP_HOST)
  end

  def impending_subscription_card_expiration_notice(subscription)
    from "upowered@uend.org"
    recipients subscription.email
    subject 'UPowered: Impending credit card expiry'
    sent_on Time.now
    body[:subscription] = subscription
    body[:edit_upowered_url] = edit_iend_subscription_url(subscription, :host => HTTP_HOST)
  end

  def tax_receipt(receipt)
    content_type "text/plain"
    recipients  "\"#{receipt.first_name} #{receipt.last_name}\" <#{receipt.email}>"
    from        "info@uend.org"
    sent_on     Time.now
    subject "UEnd: Tax Receipt"
    body = <<-TXT
Thank you for making an investment on the UEnd: website. 
The Canadian charitable tax receipt for your investment is attached to this email.
Warmest regards,
The UEnd: team

TXT
    attachment "application/pdf" do |a|
      # switched to a proxy pattern (encryption requires a lot of shenanigans)
      proxy = create_pdf_proxy(receipt)
      a.body = proxy.render(duplicate=false)
      a.filename = proxy.filename
      proxy.post_render # this removes the tmp files needed to encrypt
    end
  end

  # not sure why, but had to add these to avoid gift email rendering problems, seems
  # to be required by the rfacebook_on_rails/view_extensions
  def in_facebook_canvas?
    return false
  end
  def in_mock_ajax?
    return false
  end
 
  def friendship_request_email(friendship)
    @friendship = friendship
    @initiator  = friendship.user
    @friend     = friendship.friend
    from        "\"#{friendship.user.full_name} via UEnd\" <info@uend.org>"
    recipients  @friend.email
    @subject    = "Friendship request"
    sent_on     Time.now
    @accept_url = accept_iend_friendship_url(:id => @friendship.id, :host => HTTP_HOST)
    @decline_url = decline_iend_friendship_url(:id => @friendship.id, :host => HTTP_HOST)
  end
 
  def friendship_acceptance_email(friendship)
    @friendship = friendship
    @initiator  = friendship.user
    @friend     = friendship.friend
    from        "\"#{friendship.user.full_name} via UEnd\" <info@uend.org>"
    recipients  @initiator.email
    @subject    = "Friendship request accepted"
    sent_on     Time.now
  end

  def project_fully_funded(project)
    @project    = project
    from        "info@uend.org"
    recipients  "info@uend.org"
    @subject    = "UEnd Project Fully Funded"
    @project_url = dt_project_url(:id => @project.id, :host => HTTP_HOST)
    @admin_url   = bus_admin_project_url(:id =>@project.id, :host => HTTP_HOST)
  end

  def new_user_notification(user)
    @user       = user
    @subject    = "User signup notification"
    recipients  "jay.baydala@uend.org"
    from        "info@uend.org"
    sent_on     Time.now
  end

  protected
    def user_setup_email(user)
      @subject    = "Welcome to DonorTrust!"
      recipients  user.full_name.empty? ? "#{user.email}" : "\"#{user.full_name}\" <#{user.email}>"
      from        "info@uend.org"
      sent_on     Time.now
    end

    def gift_setup_email(gift)
      content_type "text/html"
      recipients  gift.to_name? ? "\"#{gift.to_name}\" <#{gift.to_email}>" : "#{gift.to_email}"
      # from        (gift.name? ? "#{gift.name} " : "") << "<info@uend.org>"
      # from        "\"UEnd: Team on behalf of " << (gift.name? ? "#{gift.name} " : "") << "\" <#{gift.email}>"
      # from        "#{gift.email}"
      from        gift.name ? "\"#{gift.name} via UEnd\" <info@uend.org>" : "info@uend.org"
      sent_on     Time.now
    end
end
