class BusAdmin::CustomReportUpoweredSubscriptionsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    @project = Project.admin_project
    @current_subscriptions = Subscription.find(:all, :conditions => ['begin_date > ? && (end_date IS NULL OR end_date >= ?)', @start_date, @end_date])
    @total_added = @current_subscriptions.inject(0) {|sum, s| sum + s.amount}

    respond_to do |format|
      format.csv { render_csv("subscriptions-#{@start_date}-#{@end_date}") }
      format.html
    end
  end
end