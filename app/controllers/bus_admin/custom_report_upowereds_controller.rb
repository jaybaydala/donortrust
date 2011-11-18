class BusAdmin::CustomReportUpoweredsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    if @start_date && @end_date
      @project = Project.admin_project
      @items = @project.investments.find(:all, :include => [:order, :user], :conditions => ["created_at > ? and created_at < ?", @start_date, @end_date])
      @items += @project.tips.find(:all, :include => [:order, :user], :conditions => ["created_at > ? and created_at < ?", @start_date, @end_date])
      @sum = @items.map { |i| i.amount }.sum
      @amount = @items.inject(0) {|sum, item| sum + item.amount}

      @start_active_subscribers = Subscription.find(:all, :conditions => ['begin_date < ? && (end_date IS NULL OR end_date >= ?)', @start_date, @start_date])
      @end_active_subscribers = Subscription.find(:all, :conditions => ['begin_date < ? && (end_date IS NULL OR end_date >= ?)', @end_date, @end_date])

    end

    respond_to do |format|
      format.csv { render_csv("upowered-#{@start_date}-#{@end_date}") }
      format.html
    end
  end
end
