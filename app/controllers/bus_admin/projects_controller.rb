class BusAdmin::ProjectsController < ApplicationController
#      helper "dt/groups"


  def new
    @project = Project.new     
    1.times { @project.collaborating_agencies.build }
    1.times { @project.financial_sources.build } 
#    1.times { @project.ranks.build }     
  end
  
  def index
    @page_title = 'Projects'
    @projects = Project.find(:all)#, :conditions => { :featured => 1 })
    respond_to do |format|
      format.html
    end
  end
  
   def show
    begin
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @project.name
    respond_to do |format|
      format.html
    end
  end
  
  def create
#    params[:project][:cause_ids] ||= []
    @project = Project.new(params[:project])
    @project.place_id = params[:record][:place][:id]
#    @project.place_id =   Place.find(params[:record][:id])
#    @project.place_ = (params[:place][:id]).to_i
    Contact.transaction do      
      @saved= @project.valid? && @project.save!     
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_projects_url }
        flash[:notice] = 'Project was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end  
  
  def edit     
    @page_title = "Edit Project"
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def community
    begin
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end    
    @community = @project.community
    @page_title = "#{@community.name} | #{@project.name}"
    respond_to do |format|
      format.html
    end
  end
  
    def update    
#     params[:project][:cause_ids] ||= []
#     params[:project][:sector_ids] ||= []
    @project = Project.find(params[:id])
    @project.place_id = params[:record][:place][:id]
#    @project.place_id =   1234
    if @project.update_attributes(params[:project])
    
        flash[:notice] = 'Project was successfully updated.'
      redirect_to bus_admin_project_path(@project) 
       
      else
        render :action => "edit" 
      end    
  end  
    
#  def details
#    begin 
#      @project = Project.find(params[:id])
#    rescue ActiveRecord::RecordNotFound
#      rescue_404 and return
#    end
#    @page_title = "Project Details | #{@project.name}"
#    @action_js = "http://simile.mit.edu/timeline/api/timeline-api.js"
#    respond_to do |format|
#      format.html
#    end
#  end
  
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
    @tasks =@projects.tasks  #Task.find(:all, :joins=>['INNER Join milestones on tasks.milestone_id = milestones.id'], :conditions=> ['milestones.project_id = ?', @id])

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
  
  def get_local_actions(requested_action,permitted_action)
   case(requested_action)
      when("populate_projects_places")
        return permitted_action == 'edit' || permitted_action == 'create'
      else
        return false
      end  
    end
    
  def nation
    begin
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @nation = @project.nation
    @page_title = "#{@nation.name} | #{@project.name}"
    respond_to do |format|
      format.html
    end
  end
  
  def organization
    begin
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @organization = @project.partner if @project.partner_id?
    @page_title = "#{@organization.name} | #{@project.name}"
    respond_to do |format|
      format.html
    end
  end
    
  def connect
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = "Connect | #{@project.name}"

    #facebook stuff
    if @project.place and @project.place.facebook_group_id?
      @fb_group_available = true
      @facebook_group_link = "http://www.facebook.com/group.php?gid=#{@project.place.facebook_group_id}"
      if fbsession and fbsession.is_valid?:
        gid = @project.place.facebook_group_id
        @fbid = fbsession.users_getLoggedInUser()
        begin
          @fb_group = fbsession.groups_get(:gids=>gid)
          @fb_user = fbsession.users_getInfo(:uids=>@fbid, :fields=>["name"]).user_list[0]
          members_results = fbsession.groups_getMembers(:gid=>gid)
          # weird! api seems to have bug: cannot do member.uid from group results, have to jump thru hoops
          member_ids = members_results.search("//uid").map{|uidNode| uidNode.inner_html.to_i}
          @fb_members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
          @fb_member_pages, @members = fb_paginate_array(params[:page], @fb_members , 30)
          @fb_user_in_group = true if member_ids.find{ |id| Integer(@fbid.to_s)==id}
        rescue
          @fb_group_available = false
        end
      end
    end
    respond_to do |format|
      format.html
    end
  end

  def cause
    begin
      @project = Project.find_public(params[:id])
      @cause = Cause.find(params[:cause_id]) if params[:cause_id]
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html {render :action => 'cause', :layout => false}
    end
  end
  
  def facebook_login
    # placeholder for the before_filters above: project_id_to_session, facebook_login
    # is there a more elegant way to do this? 
    # project_id_to_session: stores the project id in the (surprise) session, 
    # require_facebook_login is a rfacebook thing that bounces the user to facebook, gets a session id, and stores it in the rails session, makes the fbsession object available to controllers
  end
  def finish_facebook_login
    project_id = session[:project_id]
    session[:project_id] = nil
    respond_to do |format|
      # TODO: translate to the hash format
      # :action => 'connect', :id=>session[:project_id] 
      format.html { redirect_to dt_connect_project_path(project_id) }
    end
  end

  def timeline
    @project = Project.find(params[:id])
    @milestones = @project.milestones(:include => :tasks)
    @tasks = @project.tasks  #Task.find(:all, :joins=>['INNER Join milestones on tasks.milestone_id = milestones.id'], :conditions=> ['milestones.project_id = ?', @id])
    render :partial => 'timeline'
  end

  protected
  def project_id_to_session
    logger.debug '#####################'
    logger.debug 'FACEBOOK PROJECT_ID'
    logger.debug session[:project_id]
    session[:project_id] = params[:id]
    logger.debug session[:project_id]
  end

  def fb_paginate_array(page, array, items_per_page)
    @size = array.length
    page ||= 1
    page = page.to_i
    offset = (page - 1) * items_per_page
    pages = Paginator.new(self, array.length, items_per_page, page)
    array = array[offset..(offset + items_per_page - 1)]
    logger.debug 'FACEBOOK PAGINATION'
    logger.debug pages.inspect
    [pages, array]
  end

  @@project_ids = nil
  def before_validation_on_create
    unless self.projects.empty?
      @@project_ids = self.projects.collect { |project| project.id }
      self.projects.clear
    end 
  end
  
  def after_validation_on_create
    unless @@project_ids == nil
      self.project_ids = @@project_ids
      @@project_ids = nil
    end 
  end

    
end
