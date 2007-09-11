class GiftObserver < ActiveRecord::Observer
  def after_create(gift)
    GiftNotifier.deliver_gift(gift)
  end
end
