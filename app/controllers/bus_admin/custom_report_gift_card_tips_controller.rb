class BusAdmin::CustomReportGiftCardTipsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    if @start_date && @end_date
      orders = Order.find(:all, :include => {:cart => :items}, :conditions => ["created_at > ? AND created_at < ? ", @start_date, @end_date])
      @orders_with_tip = []
      @orders = []
      @overall_tip_percent = 0
      @overall_tip_amount = 0
      orders.each do |o|
        if o.has_gift_card?
          @orders.push o
          if o.has_tip?
            @orders_with_tip.push o
            @overall_tip_amount += o.tip_item.amount
            @overall_tip_percent += o.tip_percent
          end
        end
      end

      @overall_average_tip_amount = (@overall_tip_amount.to_f / @orders_with_tip.size)
      @overall_tip_percent = (@overall_tip_percent / @orders_with_tip.size.to_f)
      @order_tip_percent = (@orders_with_tip.size.to_f / @orders.size.to_f)*100

    end

    respond_to do |format|
      format.csv { render_csv("gift-card-tips-#{@start_date}-#{@end_date}") }
      format.html
    end
  end
end