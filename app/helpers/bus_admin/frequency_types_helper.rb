module BusAdmin::FrequencyTypesHelper

  def new_frequency_nav
    render 'bus_admin/frequency_types/new_frequency_nav'
  end    
  
  def frequency_nav
    render 'bus_admin/frequency_types/frequency_nav'
  end   

  def inactive_nav
    render 'bus_admin/frequency_types/inactive_nav'
  end    

end
