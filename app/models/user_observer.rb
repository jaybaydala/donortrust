class UserObserver < ActiveRecord::Observer
  def after_create(user)
    DonortrustMailer.deliver_user_signup_notification(user)
  end

  def after_update(user)
    DonortrustMailer.deliver_user_change_notification(user) if user.login_changed?
  end
end