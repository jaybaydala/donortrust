class BusAdmin::ProjectsController < ApplicationController
  before_filter :login_required, :check_authorization
  before_filter :login_required  
  
  active_scaffold :project do |config|
  
    config.columns = [ :name, :description, :project_status, :program, :expected_completion_date, :start_date, :end_date,
                          :dollars_raised, :dollars_spent, :total_cost, :partner, :contact, :urban_centre,
                          :milestones_count, :milestones, :sectors, :groups, :note ]
    list.columns.exclude [ :description, :expected_completion_date, :total_cost, :contact, :urban_centre, :milestones, :sectors, :milestones_count, :partner ]
    show.columns.exclude [ :milestones ]  
    update.columns.exclude [ :program, :milestones, :milestones_count, :dollars_raised, :dollars_spent, :total_cost ]
    create.columns.exclude [ :milestones_count ]
    config.columns[ :name ].label = "Project"
    config.columns[ :project_status ].label = "Status"
    config.columns[ :milestones_count ].label = "Milestones"
    config.columns[ :start_date ].label = "Start"
    config.columns[ :end_date ].label = "End"
    config.columns[ :dollars_raised ].label = "Raised"
    config.columns[ :dollars_spent ].label = "Spent"
    config.columns[ :project_status ].form_ui = :select
    config.columns[ :urban_centre ].form_ui = :select
    config.columns[ :sectors ].form_ui = :select
    config.columns[ :partner ].form_ui = :select
    config.columns[ :groups ].form_ui = :select
    
    #config.nested.add_link( "History", [:project_histories])
    config.nested.add_link( "Milestones", [:milestones])

    #config.action_links.add 'report', :label => 'Report'
    
    config.action_links.add 'index', :label => '<img src="/images/icons/you_tube.png" border=0>', :page => true, :type=> :record, :parameters =>{:controller=>"bus_admin/project_you_tube_videos"}
    config.action_links.add 'list', :label => 'Reports', :parameters =>{:controller=>'projects', :action => 'report'},:page => true
    config.action_links.add 'list', :label => 'Export to CSV', :parameters =>{:controller=>'projects', :action => 'export_to_csv'},:page => true
#    config.create.columns.exclude :project_histories
#    config.list.columns.exclude :project_histories
#    config.update.columns.exclude :project_histories
#    config.columns[:program].form_ui = :select
  end
  
  def report    
   @all_projects = []
   program_id = params[:program_id]
   if program_id != nil
     @all_projects = Project.find :all, :conditions => ["program_id = ?", program_id.to_s]
    else
      @all_projects = Project.find(:all)
   end
   @total = @all_projects.size
   render :partial => "bus_admin/projects/report" , :layout => 'application'
  end
  
  def individual_report    
   @id = params[:projectid]
   @project = Project.find(@id)
   @percent_raised = @project.get_percent_raised
   @milestones = @project.milestones.find(:all)
   render :partial => "bus_admin/projects/individual_report", :layout => 'application'
  end
#  
#  def individual_report_inline   
#   @id = params[:projectid]
#   @project = Project.get_project(@id)
#   @percent_raised = @project.get_percent_raised
#   render :partial => "bus_admin/projects/individual_report"
#  end
#  
  def export_to_csv
    @projects = Project.find(:all)  
    csv_string = FasterCSV.generate do |csv|
      # header row
      csv << ["id", "Program", "Category", "Name", "Description", "Total Cost", "Dollars Spent", "Dollars Raised", "Expected Completion Date", "Start Date", "End Date", "Status", "Contact", "Urban Centre", "Partner" ]
  
      # data rows
      @projects.each do |project|
        csv << [project.id, Program.find(project.program_id).name, project.name, project.description, project.total_cost, project.dollars_spent, project.dollars_raised, project.expected_completion_date, project.start_date, project.end_date, ProjectStatus.find(project.project_status_id).name, Contact.find(project.contact_id).fullname, UrbanCentre.find(project.urban_centre_id).name, Partner.find(project.partner_id).name]
      end
    end
    send_data csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=project.csv"
  end
  
  def show_project_note   
   @note = Project.find(params[:id]).note
   render :partial => "layouts/note"   
  end
end
