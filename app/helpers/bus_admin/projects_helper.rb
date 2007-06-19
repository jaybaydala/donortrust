module BusAdmin::ProjectsHelper
  def total_money_raised
    @total_money_raised = Project.total_money_raised
  end
  
  def number_of_projects
    @total = Project.total_projects
  end
  
  def get_projects
    @all_projects = Project.get_projects
  end
  
  def dollars_raised_column(record)
    number_to_currency(record.dollars_raised)
  end
  
  def total_cost_column(record)
    number_to_currency(record.total_cost)
  end
  
  def dollars_spent_column(record)
    number_to_currency(record.dollars_spent)
  end
  
  def project_histories_column(record)
    link_to "Show history", {:controller => 'project_histories', :action => 'list', :project_id => record.id}
  end
  
end
