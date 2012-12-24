require 'faster_csv'

class BusAdmin::SubscriptionsController < ApplicationController
  layout 'admin'

  active_scaffold do |config|
    config.list.columns = [:id, :first_name, :last_name, :email, :customer_code, :iats_customer_code, :amount, :begin_date, :end_date]
    config.action_links.add(:run_subscription, { :label => "Run NOW", :method => :post, :type => :record, :inline => false })
    config.action_links.add(:download_csv, { :label => "Download CSV", :method => :get, :type => :table, :inline => false })
  end

  def download_csv
    @subscriptions = Subscription.all
    respond_to do |format|
      format.csv { render :action => "index", :layout => false}
    end
  end

  def run_subscription
    @subscription = Subscription.find(params[:id])
    order = @subscription.process_payment
    flash[:notice] = order.inspect.html_safe
    redirect_to bus_admin_subscriptions_path
  end
end
