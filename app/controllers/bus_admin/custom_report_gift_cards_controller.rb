class BusAdmin::CustomReportGiftCardsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    if @start_date && @end_date
      orders = Order.find(:all, :include => {:cart => :items}, :conditions => ["created_at > ? AND created_at < ? ", @start_date, @end_date])
      @orders = []
      @gift_card_total = 0
      orders.each do |o|
        if o.has_gift_card?
          @orders.push o
          @gift_card_total += o.cart.gift_card_purchase_amount
        end
      end

    end

    respond_to do |format|
      format.csv { render_csv("gift-cards-#{@start_date}-#{@end_date}") }
      format.html
    end
  end
end