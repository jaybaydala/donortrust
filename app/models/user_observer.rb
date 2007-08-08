class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserNotifier.deliver_signup_notification(user)
  end

  def after_save(user)
    UserNotifier.deliver_activation(user) if user.recently_activated?
  end

  def after_update(user)
    UserNotifier.deliver_change_notification(user) if user.login_changed?
  end
end