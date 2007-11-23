module BusAdmin::ProgramsHelper
  
  def note_column(record)
     if record.note?
      link_to_remote_redbox image_tag('/images/bus_asmin/note2.png'), :url => {:controller => 'bus_admin/programs', :action => 'show_program_note', :id => record.id}
     end  
   end
end
