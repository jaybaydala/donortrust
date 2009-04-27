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
    @campaign
    render_404 and return if @campaign.nil?
    @wall_post = @campaign.wall_posts.new

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

  # GET /campaigns/new
  # GET /campaigns/new.xml
  def new
    @campaign = Campaign.new
    render :layout => 'campaign_backend'
  end

  # GET /campaigns/1/edit
  def edit
    @campaign = Campaign.find(params[:id])
    render :layout => 'campaign_backend'
  end

  # POST /campaigns
  # POST /campaigns.xml
  def create
    @campaign = Campaign.new(params[:campaign])
    @campaign.campaign_type_id = params[:campaign_type][:id]
    @campaign.creator = current_user
    @campaign.pending = true

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
      @team.picture = @campaign.picture
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
        if @participant.save
          flash[:notice] = 'Campaign was successfully created.'
          redirect_to(dt_campaign_path(@campaign))
        else
          @campaign.destroy
          @team.destroy
          flash[:notice] = 'There was an error creating your campaign, specifically in the adding of you to the default team.'
          render :action => "new"
        end
      else
        @campaign.destroy
        flash[:notice] = 'There was an error creating your campaign, specifically in the creation of the default team.'
        render :action => "new"
      end
    else
      render :action => "new"
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml
  def update
    @campaign = Campaign.find(params[:id])
    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        flash[:notice] = 'Campaign was successfully updated.'
        format.html { redirect_to(edit_dt_campaign_path(@campaign)) }
        format.xml  { head :ok }
      else
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
