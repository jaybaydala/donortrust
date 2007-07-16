module BusAdmin::PartnersHelper
#  def partner_histories_column(record)
#    link_to "Show history", {:controller => 'partner_histories', :action => 'list', :partner_id => record.id}
#  end
  
  def partner_versions_column(record)
    link_to "History", {:controller => 'bus_admin/partner_versions', :action => 'list', :partner_id => record.id }
  end
  
  def note_column(record)
     if record.note?
      link_to_remote_redbox 'View', :url => {:controller => 'bus_admin/partners', :action => 'show_note', :id => record.id}
     end  
   end
   
end
