module BusAdmin::PartnersHelper
  def note_column(record)
    if record.note?
      link_to_remote_redbox image_tag('/images/bus_admin/note2.png'), :url => {:controller => 'bus_admin/partners', :action => 'show_note', :id => record.id}
    end  
  end        
  def description_column(record)
    SuperRedCloth.new(record.description).to_html
  end        
  def business_model_column(record)
    SuperRedCloth.new(record.business_model).to_html
  end        
  def funding_sources_column(record)
    SuperRedCloth.new(record.funding_sources).to_html
  end  
  def mission_statement_column(record)
    SuperRedCloth.new(record.mission_statement).to_html
  end        
  def philosophy_dev_column(record)
    SuperRedCloth.new(record.philosophy_dev).to_html
  end        
#  def note_column(record)
#    SuperRedCloth.new(record.note).to_html
#  end
end
