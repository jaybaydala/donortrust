class UserObserver < ActiveRecord::Observer
  def after_create(user)

    # See Bug #23790 in rubyforge; users no longer have to activate themselves 
    # by clicking on a link in an email  
    #DonortrustMailer.deliver_user_signup_notification(user)
    DonortrustMailer.deliver_new_user_notification(user)

  end

  def after_update(user)
    DonortrustMailer.deliver_user_change_notification(user) if user.login_changed?
  end
end
