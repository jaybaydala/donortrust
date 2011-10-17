class BusAdmin::CustomReportGiftCardTipsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  def index
    #debugger
    if params[:custom_report_gift_card_tips].present?
      start_date_params = params[:custom_report_gift_card_tips].select{|k,v| k =~ /start_date/}.sort_by{|d| d[0] }.collect{|d| d[1].to_i }
      @start_date = DateTime.civil(*start_date_params)

      end_date_params = params[:custom_report_gift_card_tips].select{|k,v| k =~ /end_date/}.sort_by{|d| d[0] }.collect{|d| d[1].to_i }
      @end_date = DateTime.civil(*end_date_params)
    end

    if @start_date && @end_date
      orders = Order.find(:all, :conditions => ["created_at > ? AND created_at < ? ", @start_date, @end_date])
      @data = {
        :orders => orders
      }
    end
    
  end
end