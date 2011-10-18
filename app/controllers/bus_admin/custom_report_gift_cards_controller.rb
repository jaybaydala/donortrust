class BusAdmin::CustomReportGiftCardsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  def index
    if session[:custom_report_start_date].present? && session[:custom_report_end_date].present?
      @start_date = session[:custom_report_start_date]
      @end_date = session[:custom_report_end_date]
    end

    if params[:start_date].present?
      @start_date = Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
      session[:custom_report_start_date] = @start_date
      @end_date = Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)
      session[:custom_report_end_date] = @end_date
    end

    @start_date = Date.today if !@start_date
    @end_date = Date.today if !@end_date

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
  end
end