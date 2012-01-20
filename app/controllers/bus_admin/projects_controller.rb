require 'pdf/writer'
require 'string'

class BusAdmin::ProjectsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

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
    list.columns =    [ :name, :program, :project_status, :target_start_date, :public ]

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
    #config.nested.add_link( "Milestones", [:milestones])
    #config.nested.add_link( "At a glance", [:ranks])
    #config.nested.add_link( "Budget", [:budget_items])
    #config.nested.add_link( "Key Measures", [:key_measures])

    config.action_links.add 'list',  :label => 'Create',
                                     :page => true,
                                     :parameters => { :action => 'new' }
    config.action_links.add 'list',  :label => 'Reports',
                                     :page => true,
                                     :parameters => { :action => 'report' }
    config.action_links.add 'list',  :label => 'Export to CSV',
                                     :page => true,
                                     :parameters => { :action => 'export_to_csv'}
    config.action_links.add 'list',  :label => 'Pending',
                                     :page => true,
                                     :parameters => { :action => 'pending_projects'}

#    config.action_links.add 'index', :label => '<img src="/images/bus_admin/icons/you_tube.png" border="0"/>',
#                                     :page => true, :type => :record,
#                                     :parameters => { :controller => "bus_admin/project_you_tube_videos" }
#    config.action_links.add 'index', :label => '<img src="/images/bus_admin/icons/flickr.png" border="0"/>',
#                                     :page => true, :type => :record,
#                                     :parameters => { :controller =>"bus_admin/project_flickr_images" }
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

  auto_complete_for :place, :name

  #############################################################################
  # CRUD
  #############################################################################

  # called for GET on bus_admin/project
  def index
    if current_user.cf_admin?
      @projects = Project.all(:include => [:partner, :program, :project_status, :pending_project])
    else
      @projects = current_user.administrated_projects
    end
    respond_to do |format|
      format.html
    end
  end

  # called for POST on bus_admin/project
  def create
    unless current_user.administrated_partners.empty? && !current_user.cf_admin?
      @project = Project.new(params[:project])

      if params[:place] and params[:place][:name] and params[:place][:name] != ""
        assign_place_to_project(params, @project)
      end

      ActiveRecord::Base.transaction do
        @saved = @project.valid? && @project.save!
        #could do this using after_create() on the Project object,
        #but I wanted this to be in the same transaction
        if @saved
          @pending = PendingProject.new(:project_id => @project.id, :project_xml => @project.to_xml, :date_created => Date.today, :created_by => current_user.id, :is_new => true)
          @saved = @pending.save
          current_user.administrated_projects << @project
          raise Exception.new("Could not create the pending project.") unless @saved
        else
          # HACK! HACK! HACK!
          # This is not the best way to fix the problem reported by Leif at 
          # 2008-12-01 16:21 in bug #22820.
          # If you create a new project that is valid except that 4 sectors are
          # checked, the user is redirected back to the project creation screen 
          # with a descriptive error (good) but the URL says 
          # /bus_admin/projects/ (bad).
          flash[:error] = "Project was NOT created"
        end
      end

      respond_to do |format|
        if @saved
          flash[:notice] = "Project was successfully created"
          format.html {render :action => "edit"}
        else
          format.html {render :action => "new"}
        end
      end
    else
      redirect_to bus_admin_home_path
    end
  end

  # called for GET on edit_bus_admin_project_path(:id => 1)
  def edit
    session['project_id'] = params[:id]

    @user = current_user
    @project = Project.find(params[:id])
    @partner = current_user.administrated_partners.first unless current_user.administrated_partners.empty?

    begin
      pending = PendingProject.find_by_project_id(@project.id)
      @project = @project.from_xml(pending.project_xml) if pending

    rescue ActiveRecord::RecordNotFound
      #swallow - just means there was no old pending record
    end

    respond_to do |format|
      format.html
    end
  end

  # called for GET on new_bus_admin_project_path
  def new
    unless current_user.administrated_partners.empty? && !current_user.cf_admin?
      @user = current_user
      @partner = current_user.administrated_partners.first
      @project = Project.new
     
      @project.partner_id = params[:parent_id] ||= (@partner.nil?)? nil : @partner.id;

      respond_to do |format|
        format.html
      end
    else
      redirect_to bus_admin_home_path
    end
  end

  # called for GET on bus_admin/projects/:id
  def show
    redirect_to edit_bus_admin_project_path(params[:id])
  end

  # called for PUT on bus_admin/projects/:id
  def update
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

      assign_place_to_project(params, @project)

      #Hack - if we don't do this, the textiled properties are added with tags to the xml
      @project.textiled = false

      if @project.valid?
        # changes by cf admins are reflected immediately on the website
        if current_user.cf_admin? and @project.save
          flash[:notice] = 'Project was successfully updated and changes will appear publicly immediately.'
          redirect_to edit_bus_admin_project_path(@project)
        else

          #create a new PendingProject to hold the requested changes
          @pending = PendingProject.new(:project_id => @project.id, :project_xml => @project.to_xml, :date_created => Date.today, :created_by => current_user.id, :is_new => false)

          @pending.submitted_at = Time.now if params[:commit] == "Submit"

          if @pending.save
            flash[:notice] = 'Project was successfully updated, but changes will not appear publicly until approved.'
            redirect_to edit_bus_admin_project_path(@project)
          end
        end
      end
    end

    unless flash[:notice]
      flash[:notice] = 'Project could not be saved.'
      render :action => "edit"
    end
  end

  # called for PUT on bus_admin/projects/:id
  def auto_update
    # TODO: check if there were actually any changes => use changed attribute tracking of Rails 2.1

    respond_to do |wants|
      wants.js do
        @project = Project.find(params[:id])

        #there may be an old approval pending that we should get rid of
        begin
          old_pending = PendingProject.find_by_project_id(@project.id)
        rescue ActiveRecord::RecordNotFound
          #swallow - just means there was no old pending record
        end

        ActiveRecord::Base.transaction do
          #if there was an old pending record, dump it.
          old_pending.destroy if old_pending

          #only update the project attributes !!DO NOT SAVE THE PROJECT HERE!!
          @project.attributes = params[:project]

          # TODO: Combine this with the same section in the assign_place_to_project code      
          # Deal with the place that has been assigned to the project
          submitted_place = Place.find(:first, :conditions => {:name => params[:place][:name]})
          if submitted_place.nil?
            # Don't do anything because the user hasn't entered a place name yet            
            return
          else
            # This place already exists in the database
            @project.place_id = submitted_place.id if params[:place]
          end

          #Hack - if we don't do this, the textiled properties are added with tags to the xml
          @project.textiled = false

          #create a new PendingProject to hold the requested changes
          pending = PendingProject.new(:project_id => @project.id, :project_xml => @project.to_xml, :date_created => Date.today, :created_by => current_user.id, :is_new => false)
          if pending.save
            @message = 'Changes have been saved as a draft.'
          end
        end
      end
    end
  end

  # called for POST on bus_admin/projects/:id/send_pois
  def send_pois
    project = Project.find(params[:id])
    @num_sent = project.send_pois(params[:message])
  end

  #############################################################################
  # management of pending projects
  #############################################################################

  def delete_pending
    project = Project.find(params[:id])

    begin
      pending = PendingProject.find_by_project_id(project.id)
      pending.destroy if pending
    rescue ActiveRecord::RecordNotFound
      #swallow - just means there was no old pending record
    end

    redirect_to :action => 'index'
  end

  def show_pending_project_rejection
    begin
      @project = Project.find_by_id(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404 and return
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
      render_404 and return
    end
    respond_to do |format|
      format.html
    end
  end

  #get any pending projects that have not been rejected
  def pending_projects
    pp = PendingProject.find(:all, :conditions => ["rejected = false and rejection_reason is null and date_rejected is null"])
    @pending_projects = []
    pp.each {|p| @pending_projects << Project.rehydrate_from_xml(p.project_xml)}
    respond_to do |format|
      format.html
    end
  end

  #get any projects created by the logged in user that have been rejected
  def rejected_projects
    pp = PendingProject.find(:all, :conditions => ["rejected = true and rejection_reason is not null and date_rejected is not null and created_by = ?", self.current_busaccount.id])
    @rejected_projects = []
    pp.each {|p| @rejected_projects << Project.rehydrate_from_xml(p.project_xml)}
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
      render_404 and return
    end

    #Find the pending version of the project
    begin
      @pending = PendingProject.find_by_project_id(@project.id)
    rescue ActiveRecord::RecordNotFound
      render_404 and return
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
      render_404 and return
    end

    #find the pending version of the project
    begin
      @pending = PendingProject.find_by_project_id(@project.id)
    rescue ActiveRecord::RecordNotFound
      render_404 and return
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

  def auto_complete_for_place_name
    find_options = {
      :conditions => [ "LOWER(name) LIKE ? AND country_id = ? AND place_type_id = ?", '%' + params[:place][:name].downcase + '%', params[:parent], 6 ],
      :order => "name ASC",
      :limit => 10 }

    @items = Place.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end

  def clean_text(description)
      pdescription = description.strip_tags
      pdescription = pdescription.gsub("&rsquo;","'")
      pdescription = pdescription.gsub("&quote;", "\"")
      pdescription = pdescription.gsub("&amp;","&")
      pdescription = pdescription.gsub("&lt;", "<")
      pdescription = pdescription.gsub("&gt;", ">")
      pdescription = pdescription.gsub("&tilde;", "~")
      pdescription = pdescription.gsub("&sbquo;", ",")
      pdescription = pdescription.gsub("&lsquo", "`")
      pdescription = pdescription.gsub("&ndash;", "-")
      pdescription = pdescription.gsub("&mdash;", "--")
      pdescription = pdescription.gsub("&nbsp;", " ")
      pdescription = pdescription.gsub("&ldquo;", "\"")
      description = pdescription
  end
 
  def create_subagreement
    project = Project.find(params[:id])
    today = Time.now.to_formatted_s(:long)

    pdf = PDF::Writer.new
    pdf.select_font "Times-Roman"

    pdf.text "Uend: FOUNDATION\nPROJECT DESCRIPTION", :font_size => 20, :justification => :center
    pdf.text "\n", :font_size => 12
    pdf.text "This project is conducted pursuant to the Master Agency Agreement signed by the Foundation and the Agent on #{today} and all the provisions of the Master Agency Agreement are applicable to this project."
    pdf.text "\n"
    pdf.text "<b>Project Name</b>: #{project.name}"
    pdf.text "\n"
    pdf.text "<b>Project Location</b>: #{project.place.name}, #{project.country.name}"
    pdf.text "<b>Project Sector(s)</b>: " + project.sectors.collect{|c| c.name}.join(", ")
    pdf.text "\n"
    
    if project.contact
      pdf.text "<b>PM Name & Contact Info</b>: #{project.contact.last_name}, #{project.contact.first_name}"
      pdf.text "\n"
    end
     # pdescription = project.description.strip_tags
     # pdescription = pdescription.gsub("&rsquo;","'")
     # pdescription = pdescription.gsub("&quote;", "\"")
     # pdescription = pdescription.gsub("&amp;","&")
     # pdescription = pdescription.gsub("&lt;", "<")
     # pdescription = pdescription.gsub("&gt;", ">")
     # pdescription = pdescription.gsub("&tilde;", "~")
     # pdescription = pdescription.gsub("&sbquo;", ",")
     # pdescription = pdescription.gsub("&lsquo", "`")
     # pdescription = pdescription.gsub("&ndash;", "-")
     # pdescription = pdescription.gsub("&mdash;", "--")
     # pdescription = pdescription.gsub("&nbsp;", " ")
     # pdescription = pdescription.gsub("&ldquo;", "\"")

      pdf.text "<b>Project Description</b>:\n#{clean_text(project.description)}"
      pdf.text "\n"

    pdf.text "<b>Project Funds</b>: CAN$#{project.total_cost}"
    pdf.text "<b>Date of Initiation</b>: #{project.target_start_date.to_formatted_s(:long)}"
    pdf.text "<b>Date of Completion</b>: #{project.target_end_date.to_formatted_s(:long)}"
    pdf.text "\n"

    if project.milestones.size >0
      pdf.text "<b>Project Plan</b>:\n"
      project.milestones.each do |m|
        pdf.text "<i>#{m.target_date.to_formatted_s(:long) if m.target_date} - #{m.name}</i>:\n#{clean_text(m.description)}"
      end
      pdf.text "\n"
    end

    if project.budget_items.size >0
      pdf.text "<b>Project Funding Schedule</b>: "
      project.budget_items.each do |b|
        pdf.text "- #{clean_text(b.description)} - #{b.cost}"
      end
      pdf.text "\n"
    end

    if project.meas_eval_plan
      pdf.text "<b>Measurement & Evaluation Plan</b>:\n#{clean_text(project.meas_eval_plan.strip_tags)}"
      pdf.text "\n"
    end

    pdf.text "<b>Project Feedback</b>: "
    pdf.text "Every 3-4 months, submit:"
    pdf.text "1) 2-4 digital photos directly related to the project, via email or uploaded to flickr.com."
    pdf.text "2) A 50-200 word email or blog entry related to the project"
    pdf.text "3) If possible, a 1-3 minute video related to the project on YouTube.com"
    pdf.text "\n"

    if project.intended_outcome
      pdf.text "<b>Project Outcomes</b>:\n#{clean_text(project.intended_outcome.strip_tags)}"
      pdf.text "\n"
    end
    pdf.text "\n"
    pdf.text "The undersigned [Agent Name] agrees to the project in accordance with this project description and the Master Agency Agreement."
    pdf.text "\n"
    pdf.text "Dated this #{today}."
    pdf.text "\n"
    pdf.text "<b>#{project.partner.name}</b>"

    #i0 = pdf.image "../images/chunkybacon.jpg", :resize => 0.75
    #i1 = pdf.image "../images/chunkybacon.png", :justification => :center, :resize => 0.75
    #pdf.image i0, :justification => :right, :resize => 0.75

    send_data pdf.render, :filename => "#{project.partner.name}-#{project.name}-subagreement.pdf", :type => "application/pdf"
  end

  def update_location
    @project = Project.new
    @project.country_id = params[:country] if params[:country]

    render :partial => "location_form"
  end

  def update_partner
    @partner_id = params[:partner]
    render :partial => "contact_form"
  end

  def update_sectors
    sector = Sector.find(params[:sector])
    @project = Project.find(params[:project])

    render :update do |page|
      sector.causes.each do |c|
        if params[:value] == params[:sector]
          @cause = c
          page.insert_html :bottom, 'project_causes_form', :partial => 'cause_form'
          page.visual_effect :highlight, "cause_#{c.id}", :duration => 0.5
        else
          page.remove "cause_#{c.id}"
        end
      end
    end
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

	def embedded_budget_items
    render_embedded_item
	end

	def embedded_milestones
    render_embedded_item
	end

	def embedded_key_measures
    render_embedded_item
	end

	def embedded_you_tube_videos
    render_embedded_item
	end

	def embedded_flickr_images
    render_embedded_item
	end

	def embedded_collaborations
    render_embedded_item
	end

	def embedded_financial_sources
    render_embedded_item
	end

  protected
  def render_embedded_item
    session['project_id'] = params[:project_id]
    @project = Project.find(params[:project_id])
		render :layout => 'embedded'
  end

  private
  def assign_place_to_project(params, project)
    submitted_place = Place.find(:first, :conditions => {:name => params[:place][:name]})

    if submitted_place.nil?
      # Assume user wants to create a new place so insert one into the 
      # database. Note that Christmas Future will still need to approve the 
      # place.
      # TODO: Move this logic to the places_controller
      RAILS_DEFAULT_LOGGER.info('User is creating a new place called ' + params[:place][:name])
      RAILS_DEFAULT_LOGGER.info('in country ID ' + params[:project][:country_id])
      new_place = Place.new  
      new_place.name = params[:place][:name]
      new_place.parent_id = params[:project][:country_id]
      new_place.place_type_id = 6 # TODO: Do this in a more robust way without magic numbers
      new_place.save
      project.place_id = new_place.id

      # TODO: Why isn't this putting a message on the project page?
      flash[:notice] = 'A new city called ' + new_place.name + ' was created but has not yet been approved.'

      DonortrustMailer.deliver_new_place_notify(new_place);
    else
      # This place already exists in the database
      project.place_id = submitted_place.id
    end
  end
  
end
