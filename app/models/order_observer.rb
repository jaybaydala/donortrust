class OrderObserver < ActiveRecord::Observer
  def after_save(order)
    DonortrustMailer.deliver_subscription_thanks(order) if order.complete? && order.subscription
  end
end