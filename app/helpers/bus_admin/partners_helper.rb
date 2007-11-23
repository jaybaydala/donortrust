module BusAdmin::PartnersHelper
  def note_column(record)
    if record.note?
      link_to_remote_redbox image_tag('/images/bus_admin/note2.png'), :url => {:controller => 'bus_admin/partners', :action => 'show_note', :id => record.id}
    end  
  end        
  
  def description_column(record)
    if record.description != nil 
      RedCloth.new(record.description).to_html
    end
  end      
  
  def business_model_column(record)
    if record.business_model != nil 
      RedCloth.new(record.business_model).to_html
    end
  end    
  
  def funding_sources_column(record)
    if record.funding_sources != nil 
      RedCloth.new(record.funding_sources).to_html
    end
 end

  def mission_statement_column(record)
    if record.mission_statement != nil 
      RedCloth.new(record.mission_statement).to_html
    end
  end        
  
  def philosophy_dev_column(record)
    if record.philosophy_dev != nil 
      RedCloth.new(record.philosophy_dev).to_html
    end
  end        
#  def note_column(record)
#    RedCloth.new(record.note).to_html
#  end
  def partner_nav
    render 'bus_admin/partners/partner_nav'
  end
  
  def new_partner_nav
    render 'bus_admin/partners/new_partner_nav'
  end  
  
  def project_quickfacts
    render 'bus_admin/partners/project_quickfacts'
  end
    
  def partner_types
    PartnerType.find(:all)
  end
  
  def partner_statuses
    PartnerStatus.find(:all)
  end
    
end
