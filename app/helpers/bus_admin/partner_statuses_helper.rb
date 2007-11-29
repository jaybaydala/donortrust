module BusAdmin::PartnerStatusesHelper
  
  def description_column(record)
    if record.description!= nil 
      RedCloth.new(record.description).to_html
    end
  end
  
  def partner_nav
    render 'bus_admin/partner_statuses/partner_nav'
  end
  
  def new_partner_nav
    render 'bus_admin/partner_statuses/new_partner_nav'
  end  
  
  
end
