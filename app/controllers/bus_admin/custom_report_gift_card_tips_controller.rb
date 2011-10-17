class BusAdmin::CustomReportGiftCardTipsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  def index
    #debugger
    if params[:start_date].present?
      @start_date = Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
      @end_date = Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)
    end

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
  end
end