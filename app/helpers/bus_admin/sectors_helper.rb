module BusAdmin::SectorsHelper
   def description_column(record)
    if record.description != nil 
      RedCloth.new(record.description).to_html
    end
  end
  
  def sector_nav
    render 'bus_admin/sectors/sector_nav'
  end
  
  def new_sector_nav
    render 'bus_admin/sectors/new_sector_nav'
  end
  
  def inactive_nav
    render 'bus_admin/sectors/inactive_nav'
  end  
  
end
