module BusAdmin::PartnersHelper
  def note_column(record)
    if record.note?
      link_to_remote_redbox image_tag('note2.png'), :url => {:controller => 'bus_admin/partners', :action => 'show_note', :id => record.id}
    end  
  end
end
