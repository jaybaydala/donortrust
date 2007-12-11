module BusAdmin::ProgramsHelper
  
  def note_column(record)
     if record.note?
      link_to_remote_redbox image_tag('/images/bus_asmin/note2.png'), :url => {:controller => 'bus_admin/programs', :action => 'show_program_note', :id => record.id}
     end  
   end
   
  def new_nav
    render 'bus_admin/programs/new_nav'    
  end
  
  def program_nav
    render 'bus_admin/programs/program_nav'    
  end  
  
  def contact_names
    Contact.find(:all)
  end    
  
  def partner_statuses
    PartnerStatus.find(:all)
  end
  
  def get_programs
    Program.find(:all)
  end
  
end
