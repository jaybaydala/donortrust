class BusAdmin::CustomReportUpoweredsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    if @start_date && @end_date
      @project = Project.admin_project
      @items = @project.investments.find(:all, :include => [:order], :conditions => ["created_at > ? and created_at < ?", @start_date, @end_date])
      @items += @project.tips.find(:all, :include => [:order], :conditions => ["created_at > ? and created_at < ?", @start_date, @end_date])
      @sum = @items.map { |i| i.amount }.sum
      @amount = @items.inject(0) {|sum, item| sum + item.amount} 
    end
  end
end
