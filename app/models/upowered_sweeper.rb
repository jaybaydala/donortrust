class UpoweredSweeper < ActionController::Caching::Sweeper
  observe Subscription, Investment, Gift

  def after_create(record)
    StatisticWidget.all.each{|sw| sw.touch }
  end
end