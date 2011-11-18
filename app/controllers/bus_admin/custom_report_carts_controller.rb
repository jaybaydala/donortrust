class BusAdmin::CustomReportCartsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    if @start_date && @end_date
      @orders_count = Order.count(:all, :conditions => ["created_at > ? AND created_at < ? ", @start_date, @end_date])
      carts = Cart.find(:all, :include => [:items, :order], :conditions => ["created_at > ? and created_at < ?", @start_date, @end_date])
      @carts = []
      @order_total = 0
      @abandon_total = 0
      carts.each do |c|
        if c.total > 0
          @carts.push c
          if c.order.present?
            @order_total += c.total
          else
            @abandon_total += c.total
          end
        end
      end
      respond_to do |format|
        format.csv { render_csv("carts-#{@start_date}-#{@end_date}") }
        format.html
      end
    end
  end
end