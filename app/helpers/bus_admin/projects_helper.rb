module BusAdmin::ProjectsHelper
  def project_histories_column(record)
    link_to "Show history", {:controller => 'project_histories', :action => 'list', :project_id => record.id}
  end
  
  def number_of_projects
    @total = Project.total_projects
  end
  
  def get_projects
    @all_projects = Project.get_projects
  end
  
  def get_dollars_raised
    @dollars_raised = Project.get_dollars_raised
  end
#  
#  def days_remaining
#    @days_remaining = Project.days_remaining
#  end
end
