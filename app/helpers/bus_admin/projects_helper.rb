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
  
  def project_in_community_column(record)
     if record.project_in_community != nil 
       RedCloth.new(record.project_in_community).to_html
    end    
  end
  
  def other_projects_column(record)
     if record.other_projects != nil 
        RedCloth.new(record.other_projects).to_html
    end   
  end
  
  def   responsibilities_column(record)
     if record.responsibilities != nil 
       RedCloth.new(record.responsibilities).to_html
    end    
  end
  
  def project_quickfacts
    render 'bus_admin/projects/project_quickfacts'
  end
  
   def project_nav
    render 'bus_admin/projects/project_nav'    
  end

  def new_project_nav
    render 'bus_admin/projects/new_project_nav'    
  end   
  
  def place_form_column
    render 'bus_admin/projects/_place_form_column'    
  end
  
 
  def project_status_types
    ProjectStatus.find(:all)
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
  
  def get_frequency
     FrequencyType.find(:all)
  end
  
#    def interest(i)
#      if @project
#         @project.causes.include?(i)
#      else
#        false
#      end
#   end 

  def add_agency_link(name) 
      link_to_function name do |page|
        page.insert_html :bottom, :agencies, :partial => 'collaborating_agency', :object => CollaboratingAgency.new
     end
   end
   
  def add_source_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :financials, :partial => 'financial_source', :object => FinancialSource.new
     end
   end 
  
  def community_projects(project)
    if @community_projects.nil?
      @community_projects = []
      unless @project.community.nil? || @project.community.projects.nil?
        projects = Project.find_public(:all, :select => 'projects.name, projects.id', :conditions => ['projects.place_id = ? AND projects.id != ?', project.community_id, project.id])
        @community_projects = projects.collect do |project|
          [project.name, project.id]
        end
      end
    end
    @community_projects
  end
end
