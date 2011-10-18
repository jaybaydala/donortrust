class BusAdmin::CustomReportProjectsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization, :report_date_range

  def index
    active_status = ProjectStatus.active
    complete_status = ProjectStatus.completed
    @active_projects = Project.find(:all, :include => [:project_status], :conditions => ['project_status_id = ?', active_status.id])
    @complete_projects = Project.find(:all, :include => [:project_status], :conditions => ['project_status_id = ?', complete_status.id])

    @all_projects = @active_projects + @complete_projects
  end
end