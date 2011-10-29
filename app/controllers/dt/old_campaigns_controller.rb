class Dt::OldCampaignsController < DtApplicationController

  before_filter :login_required, :only => [:create, :new, :edit, :destroy]
  before_filter :is_authorized?, :except => [:show, :index, :join, :new, :create, :admin, :search, :join_options];
  before_filter :is_cf_admin?, :only => [:new, :create, :admin] # this is just here to prevent anyone but a CF admin from creating campaigns.
  include UploadSyncHelper
  after_filter :sync_uploads, :only => [:create, :update, :destroy]
  

  # GET /campaigns
  # GET /campaigns.xml
  def index
    @campaigns = OldCampaign.find_all_by_pending(false)
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml
  def show
    @campaign = OldCampaign.find(params[:id]) unless params[:id].blank?
    @campaign = OldCampaign.find_by_short_name(params[:short_name]) unless params[:short_name].blank?

    raise ActiveRecord::RecordNotFound if @campaign.nil?

    @wall_post = @campaign.wall_posts.new

    @user_on_campaign_default_team = @campaign.default_team.has_user?(current_user)
    @user_in_campaign = user_in_campaign(current_user)

    #determine if the user can close the campaign
    @can_close_campaign = @campaign.can_be_closed?(current_user)

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
    @can_create_team = false unless logged_in?

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
    @teams = OldTeam.paginate_by_campaign_id_and_pending_and_generic @campaign.id,false,false, :page => params[:team_page], :per_page => 10
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
    result = false

    @campaign.teams.each do |t|
      result = result || t.has_user?(user)
    end

    result
  end

  # GET /campaigns/new
  # GET /campaigns/new.xml
  def new
    @campaign = OldCampaign.new
    @is_new = true

    @all_projects = Project.find(:all)
    #render :layout => 'campaign_backend'
  end

  # GET /campaigns/1/edit
  def edit
    @campaign = OldCampaign.find(params[:id])
    @is_new = false
    @all_projects = Project.all

    #render :layout => 'campaign_backend'
  end

  # POST /campaigns
  # POST /campaigns.xml
  def create
    
    @campaign = OldCampaign.new(params[:campaign])
    @campaign.campaign_type_id = params[:campaign_type][:id]
    @campaign.creator = current_user
    @campaign.pending = true

    @all_projects = Project.all
    @is_new = true

    if @campaign.save
      @team = OldTeam.new
      @team.goal = @campaign.fundraising_goal
      @team.campaign = @campaign
      @team.leader = current_user
      @team.name = @campaign.name + " Team"
      @team.short_name = @campaign.short_name + '_team'
      @team.description = @campaign.description
      @team.require_authorization = @campaign.require_team_authorization
      @team.goal_currency = @campaign.goal_currency
      @team.image = @campaign.image if @campaign.image?
      @team.contact_email = @campaign.email
      @team.pending = false
      @team.generic = true

      if @team.save
        @participant = OldParticipant.new
        @participant.team = @team
        @participant.user = @team.leader
        @participant.pending = false
        @participant.goal = 0
        @participant.short_name = @campaign.short_name + '_participant'
        @participant.image = @team.image if @team.image?

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
    @campaign = OldCampaign.find(params[:id])
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
    @campaign = OldCampaign.find(params[:id])
    @campaign.destroy
    redirect_to(dt_campaigns_path)
  end

  def close
    if @campaign.funds_allocated?
      flash[:notice] = "Funds have already been allocated for this campaign, you can not allocate them again"
    else
      @campaign.close!
      flash[:notice] = "Funds successfully allocated out to selected projects and campaign archived."
    end
    redirect_to dt_campaigns_path
  end

  def admin
    @pending_campaigns = OldCampaign.find_all_by_pending(true)
    @active_campaigns = OldCampaign.find_all_by_pending(false)
    [@pending_campaigns, @active_camapaigns]
    render :layout => 'campaign_backend'
  end

  def main_page
    @campaign = OldCampaign.find_by_short_name(params[:short_name])
  end

  def activate
    @campaign = OldCampaign.find(params[:id])

    if @campaign.activate!
      CampaignsMailer.deliver_campaign_approved(@campaign)
      flash[:notice] = "Campaign Sucessfully Activated"
    else
      flash[:error] = "Campaign Not Activated"
    end

    [@pending_campaigns = OldCampaign.find_all_by_pending(true), @active_campaigns = OldCampaign.find_all_by_pending(false)]
    render :action => :activate
  end

  def manage
    @campaign = OldCampaign.find(params[:id])

    #hack to get remote pagination working
    @teams = OldTeam.paginate_by_campaign_id_and_pending_and_generic @campaign.id,false,false, :page => params[:team_page], :per_page => 10
    if(params[:team_page] != nil)
      render :partial => 'teams'
    end

    @participants = OldParticipant.paginate_by_sql ["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = ? AND t.pending = ?",@campaign.id,0,0], :page => params[:participant_page], :per_page => 10
    team = OldTeam.find_by_campaign_id_and_generic @campaign.id, true
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
    @campaign = OldCampaign.find(params[:id])
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
      [@campaign = OldCampaign.find(params[:id]), @errors = @project_limit.errors, @current_panel = 'project']
      render :partial => 'project_filters'
  end

  def remove_project_limit_from
      @project_limit = ProjectLimit.find(params[:id])
      @campaign = OldCampaign.find(@project_limit.campaign_id)
      @project_limit.destroy
      [@campaign, @current_panel = 'project']
      render :partial => 'project_filters'
  end

  def add_cause_limit_to
      @cause_limit = CauseLimit.create :cause_id => params[:cause_id], :campaign_id => params[:id]
      [@campaign = OldCampaign.find(params[:id]), @errors = @cause_limit.errors, @current_panel = 'cause']
      render :partial => 'project_filters'
  end

  def remove_cause_limit_from
      @cause_limit = CauseLimit.find(params[:id])
      @campaign = OldCampaign.find(@cause_limit.campaign_id)
      @cause_limit.destroy
      [@campaign, @current_panel = 'cause']
      render :partial => 'project_filters'
  end

  def add_place_limit_to
      @place_limit = PlaceLimit.create :place_id => params[:place_id], :campaign_id => params[:id]
      [@campaign = OldCampaign.find(params[:id]), @errors = @place_limit.errors, @current_panel = 'place']
      render :partial => 'project_filters'
  end

  def remove_place_limit_from
      @place_limit = PlaceLimit.find(params[:id])
      @campaign = OldCampaign.find(@place_limit.campaign_id)
      @place_limit.destroy
      [@campaign, @current_panel = 'place']
      render :partial => 'project_filters'
  end

  def add_partner_limit_to
      @partner_limit = PartnerLimit.create :partner_id => params[:partner_id], :campaign_id => params[:id]
      [@campaign = OldCampaign.find(params[:id]), @errors = @partner_limit.errors, @current_panel = 'partner']
      render :partial => 'project_filters'
  end

  def remove_partner_limit_from
      @partner_limit = PartnerLimit.find(params[:id])
      @campaign = OldCampaign.find(@partner_limit.campaign_id)
      @partner_limit.destroy
      [@campaign, @current_panel = 'partner']
      render :partial => 'project_filters'
  end

  def join
    @team = OldCampaign.find(params[:id]).teams[0] # base team
    redirect_to new_dt_team_participant_path(@team)
  end

  def join_options
    @campaign = OldCampaign.find(params[:id]) unless params[:id].blank?
    @campaign = OldCampaign.find_by_short_name(params[:short_name]) unless params[:short_name].blank?
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

      if(OldCampaign.find_by_short_name(@short_name) != nil)
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
      params[:search_type] = ['OldCampaign', 'Team','Participant']
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
      respond_to do |accepts|
        accepts.html { redirect_to login_path and return }
      end
    elsif ['manage','edit'].include?(action_name) && !logged_in?
      flash[:notice] = "You must be logged in to manage your team profile or details"
      respond_to do |accepts|
        accepts.html { redirect_to login_path and return }
      end
    end
    super
  end

  private
    def is_authorized?
      unless logged_in?
        flash[:notice] = "You must be logged in to view this page."
        redirect_to login_path
        return false
      end

      @campaign = OldCampaign.find(params[:id]) if params[:id]
      if @campaign && @campaign.creator != current_user and not current_user.is_cf_admin?
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
