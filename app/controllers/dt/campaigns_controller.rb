class Dt::CampaignsController < DtApplicationController

  before_filter :login_required, :only => [:create, :new, :edit, :destroy]
  before_filter :is_authorized?, :except => [:show, :index, :join, :new, :create, :admin, :search, :join_options];
  before_filter :is_cf_admin?, :only => [:new, :create, :admin] # this is just here to prevent anyone but a CF admin from creating campaigns.
  include UploadSyncHelper
  after_filter :sync_uploads, :only => [:create, :update, :destroy]
  

  # GET /campaigns
  # GET /campaigns.xml
  def index
    @campaigns = Campaign.find_all_by_pending(false)
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml
  def show
    store_location
    @campaign = Campaign.find(params[:id]) unless params[:id].blank?
    @campaign = Campaign.find_by_short_name(params[:short_name]) unless params[:short_name].blank?

    raise ActiveRecord::RecordNotFound if @campaign.nil?

    @wall_post = @campaign.wall_posts.new

    @user_on_campaign_default_team = @campaign.default_team.has_user?(current_user)
    @user_in_campaign = user_in_campaign(current_user)

    #determine if the user can close the campaign
    @can_close_campaign = @campaign.can_be_closed?

    @can_sponsor_participant = false
    if @campaign.start_date.utc < Time.now.utc
      if @campaign.raise_funds_till_date.utc > Time.now.utc
        @can_sponsor_participant = true
      end
    end

    #####################
    ## This block is for determining if users can create/join teams

    @can_join_team = true
    @can_create_team = true
    @can_join_campaign = true

    #a user that is not logged in can not create a team
    if (current_user == :false)
      @can_create_team = false
    end

    if (@campaign.default_team.participant_for_user(current_user).nil? || 
       @campaign.default_team.participant_for_user(current_user).pending)
      @can_create_team = false
    end

    if (@campaign.has_registration_fee? && !@campaign.default_team.has_user?(current_user))
      @can_create_team = false
    end

    #if the user is the campaign creator they can not join a team
    if (@campaign.owned?)
      @can_join_team = false
      @can_join_campaign = false
      @can_create_team = false
    end

    #if the user is on another team in the campaign they can not create or join a team

    if @campaign.has_participant(current_user)
      if !@campaign.default_team.has_user?(current_user)
        @can_join_team = false
      else
	      @can_create_team = false
      end

      @can_join_campaign = false
    end

    if @campaign.pending
      @can_join_team = false
      @can_join_campaign = false
      @can_create_team = false
    end

    #JSR - not sure if we need this or not, but it was in the initial implementation
    if @campaign.teams.size <= 1
      @can_join_team = false
    end

    if !@campaign.allow_multiple_teams?
      @can_create_team = false
    end

    if @campaign.teams_full? 
      @can_create_team = false
    end

    ## End of block
    #####################

    #@participants = Participant.paginate_by_campaign_id @campaign.id, :page => params[:page]

    #hack to get remote pagination working
    @teams = Team.paginate_by_campaign_id_and_pending_and_generic @campaign.id,false,false, :page => params[:team_page], :per_page => 10
    if(params[:team_page] != nil)
      render :partial => 'teams'
    end

    @participants = Participant.paginate_by_sql ["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = ? AND t.pending = ?",@campaign.id,0,0], :page => params[:participant_page], :per_page => 10
    if(params[:participant_page] != nil)
      render :partial => 'participants'
    end

    if @campaign != nil
      return @campaign
    else
      redirect_to :controller => 'campaigns', :action => 'index'
    end
  end

  def user_in_campaign(user)
    result = :false

    @campaign.teams.each do |t|
      result = result || t.has_user?(user)
    end

    result
  end

  # GET /campaigns/new
  # GET /campaigns/new.xml
  def new
    @campaign = Campaign.new
    @is_new = true

    @all_projects = Project.find(:all)
    #render :layout => 'campaign_backend'
  end

  # GET /campaigns/1/edit
  def edit
    @campaign = Campaign.find(params[:id])
    @is_new = false
    @all_projects = Project.all

    #render :layout => 'campaign_backend'
  end

  # POST /campaigns
  # POST /campaigns.xml
  def create
    @campaign = Campaign.new(params[:campaign])
    @campaign.campaign_type_id = params[:campaign_type][:id]
    @campaign.creator = current_user
    @campaign.pending = true

    @all_projects = Project.all
    @is_new = true

    if @campaign.save
      @team = Team.new
      @team.goal = @campaign.fundraising_goal
      @team.campaign = @campaign
      @team.leader = current_user
      @team.name = @campaign.name + " Team"
      @team.short_name = @campaign.short_name + '_team'
      @team.description = @campaign.description
      @team.require_authorization = @campaign.require_team_authorization
      @team.goal_currency = @campaign.goal_currency
      @team.image = @campaign.image
      @team.contact_email = @campaign.email
      @team.pending = false
      @team.generic = true
      if @team.save
        @participant = Participant.new
        @participant.team = @team
        @participant.user = @team.leader
        @participant.pending = false
        @participant.goal = 0
        @participant.short_name = @campaign.short_name + '_participant'

        @campaign.default_team_id = @team.id
        @campaign.save

        if @participant.save
          flash[:notice] = 'Campaign was successfully created.'
          redirect_to(dt_campaign_path(@campaign))
        else
          @campaign.destroy
          @team.destroy
          flash[:notice] = 'There was an error creating your campaign, specifically in the adding of you to the default team.'
          render :action => "new", :layout => 'campaign_backend'
        end
      else
        @campaign.destroy
        flash[:notice] = 'There was an error creating your campaign, specifically in the creation of the default team.'
        render :action => "new", :layout => 'campaign_backend'
      end
    else
      render :action => "new", :layout => 'campaign_backend'
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml
  def update
    @campaign = Campaign.find(params[:id])
    @all_projects = Project.all
    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        flash[:notice] = 'Campaign was successfully updated.'
        format.html { redirect_to dt_campaign_path(@campaign) }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Update not completed successfully, correct your errors and resubmit.'

        puts "Errors(#{@campaign.errors.size}): " + @campaign.errors.full_messages.to_s

        format.html { render :action => "edit" }
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml
  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy
    redirect_to(dt_campaigns_path)
  end

  def close

    if @campaign.funds_allocated
      flash[:notice] = "Funds have already been allocated for this campaign, you can not allocate them again"
      redirect_to dt_campaigns_path and return
    end

    #get the total amount that we have to allocate
    total_funds = @campaign.funds_raised

    projects_to_contribute_to = Array.new

    if not @campaign.projects.empty?
      @campaign.projects.each do |p|
          projects_to_contribute_to.push(p)
      end
    else
      projects_to_contribute_to.push(Project.find(:all, :conditions => "id not in (10,11)"))
    end

    puts "We are going to allocate #{total_funds}"

    unallocated_funds = total_funds
    project_contributions = {}
    fully_allocated_projects = Array.new

    while unallocated_funds > 0
      amount_per_project = unallocated_funds / projects_to_contribute_to.size
      puts "Attempting to allocate " + amount_per_project.to_s + " to each project"

      projects_to_contribute_to.each do |project|
        #if the project does not exist then create an entry with no money in it
        if project_contributions[project.id].nil?
          project_contributions[project.id] = 0
        end

        if project.current_need < project_contributions[project.id] + amount_per_project
          project_contributions[project.id] = project_contributions[project.id] + project.current_need
          unallocated_funds = unallocated_funds - project.current_need

          #remove the project from the array
          puts "Project " + project.name + " fulfilled, removing from array"
          fully_allocated_projects.push project
          #projects_to_contribute_to.delete(project)

          puts "allocated #{project.current_need} to project_id: #{project.id}"
        else
          project_contributions[project.id] = project_contributions[project.id] + amount_per_project
          
          unallocated_funds = unallocated_funds - amount_per_project
          puts "allocated #{amount_per_project} to project_id: #{project.id}"
        end

      end

      #delete the projects that are fully allocated from the array
      fully_allocated_projects.each do |fa_project|
        if projects_to_contribute_to.include?(fa_project)
          projects_to_contribute_to.delete(fa_project)
        end
      end

      if ((projects_to_contribute_to.empty? and unallocated_funds > 0) or 
           ((unallocated_funds / projects_to_contribute_to.size) < 0.01))
           
        puts "No more programs to contribute to"
        project_contributions[11] ||= 0

        project_contributions[11] = project_contributions[11] + unallocated_funds
        unallocated_funds = 0

      end
    end

    puts "keys: " + project_contributions.inspect

    #check and see if there are any differences between the allocated and the available and assign the difference
    if project_contributions.values.inject {|sum, value| sum + value.truncate(2)} < total_funds
      project_contributions[11] = project_contributions[11] + total_funds - project_contributions.values.inject {|sum, value| sum + value.truncate(2)}

    elsif project_contributions.values.sum > total_funds
      puts "the values are out of whach"
      project_contributions[project_contributions.keys.first] = project_contributions[project_contributions.keys.first] - (project_contributions - total_funds)
    end

    #allocate all the contributions to their projects via investments
    project_contributions.keys.each do |key|
      #if the value is zero loop and start again
      if project_contributions[key] == 0
        next
      end

      project = Project.find(key)

      investment = Investment.new
      investment.project_id = key
      investment.campaign_id = @campaign.id
      investment.amount = project_contributions[key]

      puts "allocating #{investment.amount} to #{project.name} (project_id: #{project.id})"      
      project.investments << investment
    end

    @campaign.funds_allocated = true
    @campaign.save

    flash[:notice] = "Funds successfully allocated out to selected projects and campaign archived."
    redirect_to dt_campaigns_path
  end

  def admin
    @pending_campaigns = Campaign.find_all_by_pending(true)
    @active_campaigns = Campaign.find_all_by_pending(false)
    [@pending_campaigns, @active_camapaigns]
    render :layout => 'campaign_backend'
  end

  def main_page
    @campaign = Campaign.find_by_short_name(params[:short_name])
  end

  def activate
    @campaign = Campaign.find(params[:id])

    if @campaign.activate!
      CampaignsMailer.deliver_campaign_approved(@campaign)
      flash[:notice] = "Campaign Sucessfully Activated"
    else
      flash[:error] = "Campaign Not Activated"
    end

    [@pending_campaigns = Campaign.find_all_by_pending(true), @active_campaigns = Campaign.find_all_by_pending(false)]
    render :action => :activate
  end

  def manage
    @campaign = Campaign.find(params[:id])

    #hack to get remote pagination working
    @teams = Team.paginate_by_campaign_id_and_pending_and_generic @campaign.id,false,false, :page => params[:team_page], :per_page => 10
    if(params[:team_page] != nil)
      render :partial => 'teams'
    end

    @participants = Participant.paginate_by_sql ["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = ? AND t.pending = ?",@campaign.id,0,0], :page => params[:participant_page], :per_page => 10
    team = Team.find_by_campaign_id_and_generic @campaign.id, true
    puts team
    @pending_participants = @particpants
    # @pending_participants = Participant.find_by_team_id_and_pending team.id, true
    
    puts @pending_participants
    
#   What is this ?
    if(params[:participant_page] != nil)
      render :partial => 'participants'
    end
    
    render :layout => 'campaign_backend'
  end

  def configure_filters_for
    @campaign = Campaign.find(params[:id])
    if(params[:project_page] != nil)
      @projects = Project.paginate :page => params[:project_page], :per_page => 10
      render :partial => 'configure_project_filters'
    end
    if(params[:cause_page] != nil)
      @causes = Cause.paginate :page => params[:cause_page], :per_page => 10
      render :partial => 'configure_cause_filters'
    end
    if(params[:parner_page] != nil)
      @causes = Partner.paginate :page => params[:partner_page], :per_page => 10
      render :partial => 'configure_partner_filters'
    end
  end

  def add_project_limit_to
      @project_limit = ProjectLimit.create :project_id => params[:project_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @project_limit.errors, @current_panel = 'project']
      render :partial => 'project_filters'
  end

  def remove_project_limit_from
      @project_limit = ProjectLimit.find(params[:id])
      @campaign = Campaign.find(@project_limit.campaign_id)
      @project_limit.destroy
      [@campaign, @current_panel = 'project']
      render :partial => 'project_filters'
  end

  def add_cause_limit_to
      @cause_limit = CauseLimit.create :cause_id => params[:cause_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @cause_limit.errors, @current_panel = 'cause']
      render :partial => 'project_filters'
  end

  def remove_cause_limit_from
      @cause_limit = CauseLimit.find(params[:id])
      @campaign = Campaign.find(@cause_limit.campaign_id)
      @cause_limit.destroy
      [@campaign, @current_panel = 'cause']
      render :partial => 'project_filters'
  end

  def add_place_limit_to
      @place_limit = PlaceLimit.create :place_id => params[:place_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @place_limit.errors, @current_panel = 'place']
      render :partial => 'project_filters'
  end

  def remove_place_limit_from
      @place_limit = PlaceLimit.find(params[:id])
      @campaign = Campaign.find(@place_limit.campaign_id)
      @place_limit.destroy
      [@campaign, @current_panel = 'place']
      render :partial => 'project_filters'
  end

  def add_partner_limit_to
      @partner_limit = PartnerLimit.create :partner_id => params[:partner_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @partner_limit.errors, @current_panel = 'partner']
      render :partial => 'project_filters'
  end

  def remove_partner_limit_from
      @partner_limit = PartnerLimit.find(params[:id])
      @campaign = Campaign.find(@partner_limit.campaign_id)
      @partner_limit.destroy
      [@campaign, @current_panel = 'partner']
      render :partial => 'project_filters'
  end

  def join
    @team = Campaign.find(params[:id]).teams[0] # base team
    redirect_to new_dt_team_participant_path(@team)
  end

  def join_options
    @campaign = Campaign.find(params[:id]) unless params[:id].blank?
    @campaign = Campaign.find_by_short_name(params[:short_name]) unless params[:short_name].blank?
  end

  def validate_short_name_of
    @errors = Array.new

    @short_name = params[:campaign_short_name]
    if @short_name != nil
      @short_name.downcase!

      if(@short_name =~ /\W/)
        @errors.push('You may only use Alphanumeric Characters, hyphens, and underscores. This also means no spaces.')
      end

      if(@short_name.length < 3 and @short_name.length != 0)
        @errors.push('The short name must be 3 characters or longer.')
      end

      if(Campaign.find_by_short_name(@short_name) != nil)
        @errors.push('That short name has already been used, short names must be globally unique.')
      end
    else
      @errors.push('The short name may not contain any reserved characters such as ?')
    end
    [@errors, @short_name]
  end

  def search
    #['Campaign', 'Team','Participant']
    if params[:search_type].nil?
      params[:search_type] = ['Campaign', 'Team','Participant']
    end
    search_type = params[:search_type].each{|o|o.camelize}
    @search = Ultrasphinx::Search.new(:query => params[:keywords],:class_names => search_type, :per_page => 10, :page => (params[:page].nil? ? '1': params[:page]  ))
    Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
        :before_match => '<strong style="background-color:yellow;">',
        :after_match => '</strong>',
        :chunk_separator => "...",
        :limit => 256,
        :around => 3,
        :sort_mode => 'relevance' ,
        :weights => {'name' => 10.0, 'description' => 9.0, 'team_name' => 8.0, 'team_description' => 7.0},
        :content_methods => [['name'], ['description'], ['team_name'], ['team_description']]
        })
   @search.excerpt
  end

  protected
  def access_denied
    if ['new', 'create'].include?(action_name) && !logged_in?
      flash[:notice] = "You must have an account to create a campaign, Log in below, or "+
      "<a href='/dt/signup'>click here</a> to create an account."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    elsif ['manage','edit'].include?(action_name) && !logged_in?
      flash[:notice] = "You must be logged in to manage your team profile or details"
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    end
    super
  end

  private
    def is_authorized?
      if (current_user == :false)
        flash[:notice] = "You must be logged in to view this page."
        redirect_to dt_login_path
	return false
      end

      @campaign = Campaign.find(params[:id])
      if @campaign.creator != current_user and not current_user.is_cf_admin?
        flash[:notice] = 'You are not authorized to view this page.'
        redirect_to dt_campaign_path(@campaign)
      end
    end

    def is_cf_admin?
      if not current_user.is_cf_admin?
        flash[:noticed] = 'You are not authorized to view this page.'
        redirect_to dt_campaigns_path
      end
    end

end
