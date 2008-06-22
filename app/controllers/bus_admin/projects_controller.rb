class BusAdmin::ProjectsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :project do |config|
    config.actions = [:show, :list, :nested]
  
    config.columns =  [ :name, :description, :program, :project_status,  :target_start_date,
                        :target_end_date, :causes, :actual_start_date, :actual_end_date,
                        :dollars_spent, :total_cost, :partner, :contact, :place,
                        :milestone_count, :ranks, :milestones,:key_measures, :sectors,
                        :public, :note, :featured, :blog_url, :rss_url, :frequency_type,
                        :intended_outcome, :meas_eval_plan, :project_in_community,
                        :other_projects, :causes, :collaborating_agencies, :financial_sources,
                        :lives_affected ]      
    list.columns =    [ :name, :program, :project_status, :target_start_date, :featured ]

    #update.columns.exclude [ :program, :milestones, :milestone_count, :key_measures ]
    #create.columns.exclude [ :milestones, :milestone_count, :key_measures  ]

    config.columns[ :name ].label = "Project"
    config.columns[ :project_status ].label = "Status"
    config.columns[ :milestone_count ].label = "Milestones"
    config.columns[ :target_start_date ].label = "Target Start"
    config.columns[ :target_end_date ].label = "Target End"
    config.columns[ :actual_start_date ].label = "Actual Start"
    config.columns[ :actual_end_date ].label = "Actual End"
    config.columns[ :dollars_spent ].label = "Spent"
    config.columns[ :featured ].label = "Featured?"    
    config.columns[ :project_in_community ].label = "How project fits into community development"
    config.columns[ :meas_eval_plan ].label = "Measurement&nbsp;and Evaluation Plan"
    config.columns[ :frequency_type ].label = "Frequency&nbsp;of&nbsp;Feedback"   
    #config.nested.add_link( "History", [:project_histories])
    config.nested.add_link( "Milestones", [:milestones])
    config.nested.add_link( "At a glance", [:ranks])
    config.nested.add_link( "Budget", [:budget_items])
    config.nested.add_link( "Key Measures", [:key_measures])
    
    config.action_links.add 'list',  :label => 'Create',
                                     :page => true,
                                     :parameters => { :action => 'new' }
    config.action_links.add 'list',  :label => 'Reports',
                                     :page => true,
                                     :parameters => { :action => 'report' }
    config.action_links.add 'list',  :label => 'Export to CSV',
                                     :page => true, 
                                     :parameters => { :action => 'export_to_csv'}
                                     
    config.action_links.add 'index', :label => '<img src="/images/bus_admin/icons/you_tube.png" border="0"/>',
                                     :page => true, :type => :record,
                                     :parameters => { :controller => "bus_admin/project_you_tube_videos" }
    config.action_links.add 'index', :label => '<img src="/images/bus_admin/icons/flickr.png" border="0"/>',
                                     :page => true, :type => :record,
                                     :parameters => { :controller =>"bus_admin/project_flickr_images" }    
    config.action_links.add 'list',  :label => 'KPI Reports', 
                                     :page => true, :type => :record,
                                     :parameters => { :action => 'kpi_report'}
    config.action_links.add 'list',  :label => 'Timeline',
                                     :page => true, :type => :record,
                                     :parameters => { :action => 'showProjectTimeline'}
    config.action_links.add 'list',  :label => 'Edit',
                                     :page => true, :type => :record,
                                     :parameters => { :action => 'edit'}
  end

  #############################################################################
  # CRUD
  #############################################################################

  # called for GET on bus_admin/project
  def index2
    # TODO: only list projects that the user has access to
    
    @projects = Project.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  # called for POST on bus_admin/project
  def create
    @project = Project.new(params[:project])
    @project.save!
    respond_to do |format|
      format.html do
        flash[:notice] = "Project was successfully created"
        redirect_to bus_admin_project_url(@project)
      end
    end
  end

  # called for GET on edit_bus_admin_project_path(:id => 1)
  def edit
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  # called for GET on new_bus_admin_project_path
  def new
    @project = Project.new
    respond_to do |format|
      format.html
    end
  end
  
  # called for GET on bus_admin/projects/:id
  def show2
    redirect_to edit_bus_admin_project_path(params[:id])
  end
  
  # called for PUT on bus_admin/projects/:id
  def update
    @project = Project.find(params[:id])
    @project.attributes = params[:project]
    
    if @project.save                            
      flash[:notice] = 'Project was successfully updated, but changes will not appear publicly until approved.'
      redirect_to bus_admin_project_path(@project)
    else
      render :action => "edit"
    end
  end

  #############################################################################
  # additional project methods
  #############################################################################
  
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
  
  def kpi_report
    @id = params[:id]
    @project = Project.find(@id)
    @measures = @project.key_measures.find(:all)
    render :partial => "bus_admin/projects/kpi_report", :layout => 'application'
  end
  
  def byProject
    @id  = params[:projectId]
    @projects = Project.find(@id)
    @milestones = @projects.milestones(:include => [:tasks])
    @tasks = @projects.tasks  #Task.find(:all, :joins=>['INNER Join milestones on tasks.milestone_id = milestones.id'], :conditions=> ['milestones.project_id = ?', @id])

    render :partial => 'timeline_json'
  end
  
  def showProjectTimeline
    @id  = params[:id]
    @projects = Project.find(@id)
    @milestones = @projects.milestones(:order => "target_date desc")
    @startDate =  (@projects.target_start_date >> 1).strftime("%b %d %Y")
    render :partial => 'bus_admin/projects/showProjectTimeline'
  end
  
  def export_to_csv
    @projects = Project.find(:all)  
    csv_string = FasterCSV.generate do |csv|
      # header row
      csv << ["id", "Program", "Category", "Name", "Description", "Total Cost", "Dollars Spent", "Dollars Raised", "Expected Completion Date", "Start Date", "End Date", "Status", "Contact", "Urban Centre", "Partner" ]

      # data rows
      @projects.each do |project|
        csv << [project.id, Program.find(project.program_id).name, project.name, project.description, project.total_cost, project.dollars_spent, project.dollars_raised, project.expected_completion_date, project.start_date, project.end_date, ProjectStatus.find(project.project_status_id).name, Contact.find(project.contact_id).fullname, place.find(project.place_id).name, Partner.find(project.partner_id).name]
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

  def get_local_actions(requested_action,permitted_action)
    case(requested_action)
    when("export_to_csv" || "show_project_note")
      return permitted_action == 'show'
    when("populate_projects_places")
      return permitted_action == 'edit' || permitted_action == 'create'
    else
      return false
    end  
  end   

  def populate_project_places
    @filterMessage = ""
    @places = nil
    @selectedPlace = nil
    @parentString = ""
    @boolShowTop = true

    if params[:record_place] != nil and params[:record_place] != ""
      @selectedPlace = Place.find(params[:record_place])
    end

    if params[:posttype] == "top"
      #Get all records with parent_id == null
      @boolShowTop = false
      @places = Place.find :all, :conditions => ["parent_id is null"]        
    else
      if params[:posttype] == "down"
        if params[:record_place] == nil or params[:record_place] == ""
          #if selected record was "please select a Place"
          @boolShowTop = false
          @places = Place.find :all, :conditions => ["parent_id is null"]
        else
          #selected record is a proper value
          @boolShowTop = true
          @parentString = Place.getParentString(@selectedPlace)
          @places = Place.find :all, :conditions => ["parent_id = ?", @selectedPlace.id]
        end

        #if the selected record had no children, reload with selected / peers and update message
        if @places.length == 0
          @places = Place.find :all, :conditions => ["parent_id = ?", @selectedPlace.parent_id]
          @filterMessage = @selectedPlace.name + " has no children."
        end
      end
    end

    render :partial => "bus_admin/projects/place_form"
  end

end
