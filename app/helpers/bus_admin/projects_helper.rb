module BusAdmin::ProjectsHelper
  def total_money_raised
    @total_money_raised = Project.total_money_raised
  end
  
  def total_project_costs
    @total_costs = Project.total_costs
  end
  
  def total_money_spent
    @total_money_spent = Project.total_money_spent
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
