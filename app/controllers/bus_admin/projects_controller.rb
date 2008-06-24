class BusAdmin::ProjectsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :project do |config|
    config.actions = [ :list, :nested, :search ]
  
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
    # TODO: check if access is authorized
    
    @project = Project.find(params[:id])
    
    #there may be an old approval pending that we should get rid of
    begin
      @old_pending = PendingProject.find_by_project_id(@project.id)
    rescue ActiveRecord::RecordNotFound
      #swallow - just means there was no old pending record
    end
    
    ActiveRecord::Base.transaction do
      #if there was an old pending record, dump it.
      if @old_pending
        @old_pending.destroy
      end
      
      #only update the project attributes !!DO NOT SAVE THE PROJECT HERE!!
      @project.attributes = params[:project]
      #Hack - if we don't do this, the textiled properties are added with tags to the xml
      @project.textiled = false
      #create a new PendingProject to hold the requested changes
      @pending = PendingProject.new(:project_id => @project.id, :project_xml => @project.to_complete_xml, :date_created => Date.today, :created_by => current_user.id, :is_new => false)
      if @pending.save                            
        flash[:notice] = 'Project was successfully updated, but changes will not appear publicly until approved.'
        redirect_to edit_bus_admin_project_path(@project)
      else
        render :action => "edit"
      end
    end    
  end

  #############################################################################
  # management of pending projects
  # TODO for Adrian: integrate properly
  #############################################################################
  
  def show_pending_project_rejection
    begin
      @project = Project.find_by_id(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html {render :partial => "show_pending_project_rejection"}
    end
  end
  
  #Shows a pending project in read-only mode
  def show_pending_project
    begin
      @pending = PendingProject.find_by_project_id(params[:id])
      @rehydrated = Project.rehydrate_from_xml(@pending.project_xml)
      
      unless @pending.is_new
        @original = Project.find_by_id(params[:id])
        @differences = Differ.new(@original, @rehydrated)
      end
      
      @wrapper = PendingWrapper.new(@pending, @rehydrated)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  #get any pending projects that have not been rejected
  def pending_projects
    pp = PendingProject.find(:all, :conditions => ["rejected = false and rejection_reason is null and date_rejected is null"])
    @pending_projects = []
    pp.each {|p| @pending_projects << PendingWrapper.new(p, Project.rehydrate_from_xml(p.project_xml))}
    respond_to do |format|
      format.html
    end
  end
  
  #get any projects created by the logged in user that have been rejected
  def rejected_projects
    pp = PendingProject.find(:all, :conditions => ["rejected = true and rejection_reason is not null and date_rejected is not null and created_by = ?", self.current_busaccount.id])
    @rejected_projects = []
    pp.each {|p| @rejected_projects << PendingWrapper.new(p, Project.rehydrate_from_xml(p.project_xml))}
    respond_to do |format|
      format.html
    end
  end
  
   #This method should return us to the list of project requiring approval
  def approve_project
    #find the project
    begin
      @project = Project.find_by_id(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    
    #Find the pending version of the project
    begin
      @pending = PendingProject.find_by_project_id(@project.id)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    
    #If the project is not new, we need to apply the pending changes to the project and save it.
    #If the project IS new, all we need to do is delete the PendingProject
    @success = true
    @new = @pending.is_new
      unless @new
        @project = Project.rehydrate_from_xml(@pending.project_xml)
        @project.updated_at = Date.today
        @success = @project.update
      end
      if @success
        if @pending.destroy
          if @new
            flash[:notice] = "Successfully approved the new project."
          else
            flash[:notice] = "Successfully approved and applied changes to the project."
          end
          respond_to do |format|
            format.html { redirect_to :action => :pending_projects }
          end
      else
        raise Exception.new("Could not delete PendingProject for the project.")
      end
    else
      raise Exception.new("Could not update the project.")
    end
  end
  
  #This method should return us to the list of project requiring approval
  def reject_project
    #find the project
    begin
      @project = Project.find_by_id(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    
    #find the pending version of the project
    begin
      @pending = PendingProject.find_by_project_id(@project.id)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    
    #mark the pending version as rejected, with the reason, the date rejected, and who rejected it. 
    @pending.rejected = true
    @pending.rejection_reason = params[:reason][:reason]
    @pending.rejected_by = self.current_busaccount
    @pending.date_rejected = Date.today
    if @pending.save
      if @pending.is_new
        flash[:notice] = "Successfully rejected the new project."
      else
        flash[:notice] = "Successfully rejected the changes to the project."
      end
      respond_to do |format|
            format.html { redirect_to :action => :pending_projects }
      end
    else
      raise Exception.new("Could not save the PendingProject.")
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
