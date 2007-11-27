module BusAdmin::GroupsHelper
  
  def public_column(record)
    result = "Yes"
    unless record.public 
      result = "No"   
    end
  return result
end

  def description_column(record)
    if record.description!= nil 
      RedCloth.new(record.description).to_html
    end
  end  
  
  def new_group_nav
    render 'bus_admin/groups/new_group_nav'
  end    
  
  def group_nav
    render 'bus_admin/groups/group_nav'
  end   
  
    
  def group_types
    GroupType.find(:all)
  end
end
