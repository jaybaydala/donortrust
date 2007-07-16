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
  
  def note_column(record)
     if record.note?
      link_to_remote_redbox image_tag('note2.png'), :url => {:controller => 'bus_admin/projects', :action => 'show_project_note', :id => record.id}
     end  
   end
end
