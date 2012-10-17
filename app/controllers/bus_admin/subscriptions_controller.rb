require 'faster_csv'

class BusAdmin::SubscriptionsController < ApplicationController
  active_scaffold do |config|
    config.action_links.add(:run_subscription, { :label => "Run NOW", :method => :post, :type => :record, :inline => false })
  end

  def index
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
