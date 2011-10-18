class BusAdmin::CustomReportUpoweredsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    @project = Project.admin_project

    if @start_date && @end_date
      
    end
  end
end