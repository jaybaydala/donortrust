module BusAdmin::MilestoneStatusesHelper
  def description_column(record)
    if record.description != nil  
      RedCloth.new(record.description).to_html
    end
  end  

  def new_milestone_nav
    render 'bus_admin/milestone_statuses/new_milestone_nav'
  end    
  
  def milestone_nav
    render 'bus_admin/milestone_statuses/milestone_nav'
  end  
  
  def inactive_nav
    render 'bus_admin/milestone_statuses/inactive_nav'
  end      
  
end
