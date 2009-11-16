require 'faster_csv'

class BusAdmin::SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.all
    respond_to do |format|
      format.csv { render :action => "index", :layout => false}
    end
  end
end