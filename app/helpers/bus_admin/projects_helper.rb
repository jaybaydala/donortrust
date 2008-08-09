module BusAdmin::ProjectsHelper
 
  def dollars_raised_column(record)
    number_to_currency(record.dollars_raised)
  end
  
  def total_cost_column(record)
    number_to_currency(record.total_cost)
  end
  
  def dollars_spent_column(record)
    number_to_currency(record.dollars_spent)
  end
  
  def get_continents
    Place.find :all,
               :conditions => "place_type_id = 1",
               :order => 'name ASC'
  end
  
  def get_country(parent)
    if parent
      Place.find :all,
                :conditions => "parent_id = #{parent} AND place_type_id = 2",
                :order => 'name ASC'
    else
      []
    end 
  end

  def get_partners
    Partner.find(:all)
  end
  
  def get_contacts
    Contact.find(:all)
  end
  
  def get_programs
    Program.find(:all)
  end
  
  def get_places
    Place.find(:all)
  end  
  
  def get_frequency
     FrequencyType.find(:all)
  end
  
  def note_column(record)
     if record.note?
      link_to_remote_redbox image_tag('/images/bus_admin/note2.png'), :url => {:controller => 'bus_admin/projects', :action => 'show_project_note', :id => record.id}
     end  
   end
  
  def description_column(record)
     if record.description != nil 
       RedCloth.new(record.description).to_html
    end    
  end
  
  def intended_outcome_column(record)
     if record.intended_outcome != nil 
        RedCloth.new(record.intended_outcome).to_html
    end   
  end
  
  def meas_eval_plan_column(record)
     if record.meas_eval_plan != nil 
      RedCloth.new(record.meas_eval_plan).to_html
    end    
  end
  
  def periodically_save_form(id, target, seconds)
    %Q{
      <script language="javascript" type="text/javascript">
      //<![CDATA[
      new PeriodicalExecuter(
        function() {
          new Ajax.Request(
            '#{target}',
            { asynchronous:true, evalScripts:true, method:'put', parameters:$('#{id}').serialize() }
          )
        }, 
        #{seconds})
      //]]>
      </script>
    }
  end
  
  def project_in_community_column(record)
     if record.project_in_community != nil 
       RedCloth.new(record.project_in_community).to_html
    end    
  end
  
  def project_status_types
    ProjectStatus.find(:all)
  end
  
  def other_projects_column(record)
     if record.other_projects != nil 
        RedCloth.new(record.other_projects).to_html
    end   
  end
  
  def responsibilities_column(record)
     if record.responsibilities != nil 
       RedCloth.new(record.responsibilities).to_html
    end    
  end
    
end
