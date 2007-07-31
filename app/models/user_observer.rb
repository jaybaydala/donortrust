class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserNotifier.deliver_signup_notification(user)
  end

  def after_save(user)
    UserNotifier.deliver_activation(user) if user.recently_activated?
  end

  def before_update(user)
    old_login = User.find_by_id(user.id).login
    UserNotifier.deliver_change_notification(user) if old_login != user.login
  end
end