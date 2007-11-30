module BusAdmin::CausesHelper
    def description_column(record)
    if record.description != nil 
      RedCloth.new(record.description).to_html
    end
  end 
  
  def new_cause_nav
    render 'bus_admin/causes/new_cause_nav'
  end    
  
  def cause_nav
    render 'bus_admin/causes/cause_nav'
  end  
  
  def inactive_nav
    render 'bus_admin/causes/inactive_nav'
  end     
  
end
