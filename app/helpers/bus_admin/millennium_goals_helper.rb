module BusAdmin::MillenniumGoalsHelper
  def description_column(record)
    if record.description != nil 
      RedCloth.new(record.description).to_html
    end
  end  
  
  def goal_nav
    render 'bus_admin/millennium_goals/goal_nav'
  end
  
  def new_goal_nav
    render 'bus_admin/millennium_goals/new_goal_nav'
  end  
  
end
