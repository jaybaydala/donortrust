module BusAdmin::PlaceSectorsHelper  
  
  def sector_nav
    render 'bus_admin/place_sectors/sector_nav'
  end
  
  def new_sector_nav
    render 'bus_admin/place_sectors/new_sector_nav'
  end
  
  def get_sectors
    Sector.find(:all) 
  end
 
  def place_form_column
    render 'bus_admin/place_sectors/_place_form_column'    
  end
  
end
