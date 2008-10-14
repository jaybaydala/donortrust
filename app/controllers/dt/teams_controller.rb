class Dt::TeamsController < DtApplicationController

  before_filter :find_campaign, :except => [:validate_short_name_of]
  before_filter :find_team, :only => [:show, :create, :edit, :update, :destroy, :join, :activate], :except => [:validate_short_name_of, :index]
  before_filter :login_required, :except => [:show,:index]
  before_filter :check_if_in_team

  # GET /dt_teams
  # GET /dt_teams.xml
  def index
    @teams = Team.paginate_by_campaign_id_and_pending_and_generic params[:campaign_id], false, false, :page => params[:page], :per_page => 20
  end

  # GET /dt_teams/1
  # GET /dt_teams/1.xml
  def show
    @participants = Participant.paginate_by_team_id_and_pending @team.id, false, :page => params[:participant_page], :per_page => 10
    if(params[:participant_page] != nil)
      render :partial => 'participants'
    end
  end

  # GET /dt_teams/new
  # GET /dt_teams/new.xml
  def new
    @team = Team.new
    if @campaign.pending?
      flash[:notice] = "This campaign is still pending, and thus cannot be joined."
      redirect_to dt_campaign_path(@campaign)
    end
    if !@campaign.allow_multiple_teams?
      flash[:notice] = "You cannot create a team for this campaign."
      redirect_to dt_campaign_path(@campaign)
    end
  end

  # GET /dt_teams/1/edit
  def edit
  end

  # POST /dt_teams
  # POST /dt_teams.xml
  def create
    @team = Team.new(params[:team])
    @team.campaign = @campaign
    @team.leader = current_user
    @team.pending = @campaign.require_team_authorization?
    @team.generic = false

    @team.goal = 0 if @team.goal ==nil

    #validation pulled here to only run on create
    if((Team.find_by_user_id_and_campaign_id(current_user.id,@campaign.id) != nil) && (@campaign.user_id != current_user.id))
      flash[:notice] = "You have already created a team for this campaign and cannot create another one."
    else
      if @team.save
        @participant = Participant.new
        @participant.team = @team
        @participant.user = current_user
        @participant.pending = false
        @participant.goal = 0
        @participant.short_name = @team.short_name + '_participant'

        if @participant.save
          if @team.pending
            flash[:notice] = 'Team was successfully created, you will be contacted once it has been approved.'
          else
            flash[:notice] = 'Team was successfully created.'
          end
          redirect_to(dt_team_path(@team))
        else
          flash[:notice] = 'There was an error creating your team.'
        end
      else
        render :action => "new"
      end
    end
  end

  # PUT /dt_teams/1
  # PUT /dt_teams/1.xml
  def update
    if @team.update_attributes(params[:team])
      flash[:notice] = 'Team was successfully updated.'
      redirect_to(edit_dt_team_path(@team))
    else
      render :action => "edit"
    end
  end

  # DELETE /dt_teams/1
  # DELETE /dt_teams/1.xml
  def destroy
    @campaign = @team.campaign
    if not @team.generic?
        @team.destroy
        flash[:notice] = 'Team Removed.'
    else
        flash[:notice] = 'You may not destroy the default team.'
    end
    redirect_to(dt_campaign_path(@campaign))
  end

  def manage
    @team = Team.find(params[:id])
    @applicants = Participant.find(:all, :conditions => { :pending => true, :team_id => @team.id })
    @participants = Participant.find(:all, :conditions => { :pending => false, :team_id => @team.id })
    [@applicants, @participants, @team]
  end

  def admin
    @teams = Team.find(:all) unless params[:campaign_id] != nil
    @teams = Team.find_by_campaign_id(params[:campaign_id]) unless params[:campaign_id] == nil
  end

  def join!
    if @team.pending?
      flash[:notice] = "This team has not yet been approved, thus you may not join it."
    else
      if @team.campaign.participating?(current_user)
        flash[:notice] = "You are already participating in this campaign, thus you may not join another team."
      else
        if @team.users.include?(current_user)
          flash[:notice] = "You are already a member of this team!"
        else
          @team_member = TeamMember.new
          @team_member.user = current_user
          @team_member.team = @team
          if @team_member.save
            flash[:notice] = "Welcome to the team!"
            if @team.require_authorization?
              flash[:notice] = flash[:notice] + " You will be contacted when your membership has been approved."
            end
          else
            flash[:notice] = "There was an error joining this team!"
          end
        end
      end
    end
    redirect_to dt_team_path(@team)
  end

  def approve
    @team = Team.find(params[:id]) unless params[:id] == nil
    if @team.approve!
      flash[:notice] = "#{@team.name} approve!"
      redirect_to manage_dt_campaign_path(@campaign)
      # send email to team admin when approved
      CampaignsMailer.deliver_team_approved(@team.campaign, @team)
    else
      flash[:notice] = "There was an error approving that team, please try again."
    end
  end

  def deny
    # placeholder for denying a team that wants to join a campaign without destroying it

    # send email to team admin when declined
    # CampaignsMailer.deliver_team_declined(@team.campaign, @team)
  end

  def validate_short_name_of
    @errors = Array.new
    @short_name = params[:team_short_name]
    if @short_name != nil
      @short_name.downcase!

      if(@short_name =~ /\W/)
        @errors.push('You may only use Alphanumeric Characters, hyphens, and underscores. This also means no spaces.')
      end

      if(@short_name.length < 3 and @short_name.length != 0)
        @errors.push('The short name must be 3 characters or longer.')
      end

      if(Team.find_by_short_name_and_campaign_id(@short_name,params[:campaign_id]) != nil)
        @errors.push('That short name has already been used, short names must be unique to each campaign.')
      end
    else
      @errors.push('The short name may not contain any reserved characters such as ?')
    end
    [@errors, @short_name]
  end

  protected
  def access_denied
    puts 'in team acc denied'
    if ['join', 'new', 'create'].include?(action_name) && !logged_in?
      flash[:notice] = "You must have an account to create a team in this campaign.  Log in below, or "+
      "<a href='/dt/signup'>click here</a> to create an account."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    elsif ['manage','edit'].include?(action_name) && !logged_in?
      flash[:notice] = "You must be logged in to manage your team profile or details. Please log in."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    end
    super
  end

  private
  def find_campaign
    @campaign = Campaign.find(params[:campaign_id]) unless params[:campaign_id].blank?
    @campaign = Campaign.find_by_short_name(params[:short_campaign_name]) unless params[:short_campaign_name].blank?

    if @campaign == nil
      @campaign = Team.find(params[:id]).campaign unless params[:id] == nil
    end
    @campaign
  end

  def find_team
    @team = Team.find(params[:id]) unless params[:id].blank?
    @team = Team.find_by_short_name(params[:short_name]) unless params[:short_name].blank?
  end

  def check_if_in_team
    find_campaign
    if @campaign.participating?(current_user)

    end
  end
end