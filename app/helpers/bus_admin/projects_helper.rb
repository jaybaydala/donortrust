module BusAdmin::ProjectsHelper
 
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
