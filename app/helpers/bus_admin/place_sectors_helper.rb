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
    render :partial => 'bus_admin/shared/generic_place_form_column', :locals => {:item => @sector, :named_route => 'populate_place_sector_places'}    
  end
  
end
