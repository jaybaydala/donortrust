class Dt::OldOldTeamsController < DtApplicationController

  before_filter :find_campaign, :except => [:validate_short_name_of]
  before_filter :find_team, :only => [:show, :create, :edit, :update, :destroy, :join, :leave, :activate], :except => [:validate_short_name_of, :index]
  before_filter :login_required, :except => [:show,:index]
  # before_filter :check_if_in_team
  include UploadSyncHelper
  after_filter :sync_uploads, :only => [:create, :update, :destroy]

  # GET /dt_teams
  # GET /dt_teams.xml
  def index
    @teams = OldTeam.paginate_by_campaign_id_and_pending_and_generic params[:campaign_id], false, false, :page => params[:page], :per_page => 20
  end

  # GET /dt_teams/1
  # GET /dt_teams/1.xml
  def show
    participant = OldParticipant.find(:first, :conditions => {:team_id => @team.id, :user_id => current_user.id})
    @can_leave_team = logged_in? && participant && participant.can_leave_team?
    @can_join_team = !logged_in? || current_user.can_join_team?(@team)

    @participants = OldParticipant.paginate_by_team_id_and_pending_and_active @team.id, false, true, :page => params[:participant_page], :per_page => 10
    if(params[:participant_page] != nil)
      render :partial => 'participants'
    end
  end

  # GET /dt_teams/new
  # GET /dt_teams/new.xml
  def new
    if @campaign.has_registration_fee? && !@campaign.default_team.has_user?(current_user)
      flash[:notice] = "Because this campaign has a registration fee, you must first join the campaign before you can create a team"
      redirect_to dt_campaign_path(@campaign) and return
    end

    @team = OldTeam.new
    if @campaign.has_participant(current_user) && !@campaign.default_team.has_user?(current_user)
      flash[:notice] = "You are already in another team in this campaign, you can not create a team."
      redirect_to dt_campaign_path(@campaign) and return
    end

    if @campaign.pending?
      flash[:notice] = "This campaign is still pending, and thus cannot be joined."
      redirect_to dt_campaign_path(@campaign) and return
    end
    if !@campaign.allow_multiple_teams?
      flash[:notice] = "You cannot create a team for this campaign."
      redirect_to dt_campaign_path(@campaign) and return
    end
  end

  # GET /dt_teams/1/edit
  def edit
  end

  # POST /dt_teams
  # POST /dt_teams.xml
  def create
    @team = OldTeam.new(params[:team])
    @team.campaign = @campaign
    @team.leader = current_user
    @team.pending = @campaign.require_team_authorization?
    @team.generic = false
    @team.goal ||= 0

    if @team.save
      @participant = OldParticipant.new
      @participant.team = @team
      @participant.user = current_user
      @participant.active = true
      @participant.pending = false
      @participant.goal = 0
      @participant.short_name = current_user.profile.short_name || @team.short_name + '_participant'

      if @participant.save
        if (@team.campaign.default_team.has_user?(current_user))
          old_participant = @team.campaign.default_team.participant_for_user(current_user)
          old_participant.active = false
          old_participant.save
        end

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

    #move all the current team members into the default team
    @team.participants.each do |p|
      p.team_id = @campaign.default_team.id
      p.save
    end

    #move all the pledges to the team up to the campaign
    @team.pledges.each do |p|
      p.team_id = nil;
      p.campaign_id = @campaign.id
      p.save
    end

    if not @team.generic?
        @team.destroy
        flash[:notice] = 'Team Removed.'
    else
        flash[:notice] = 'You may not destroy the default team.'
    end
    redirect_to(dt_campaign_path(@campaign))
  end

  def manage
    @team = OldTeam.find(params[:id])
    @applicants = OldParticipant.find(:all, :conditions => { :pending => true, :team_id => @team.id })
    @participants = OldParticipant.find(:all, :conditions => { :pending => false, :team_id => @team.id })
    [@applicants, @participants, @team]
  end

  def admin
    @teams = OldTeam.find(:all) unless params[:campaign_id] != nil
    @teams = OldTeam.find_by_campaign_id(params[:campaign_id]) unless params[:campaign_id] == nil
  end

  def join!
    if @team.pending?
      flash[:notice] = "This team has not yet been approved, thus you may not join it."
    else
      if !@team.campaign.can_join_team?(current_user)
        flash[:notice] = "You are already participating on a team in this campaign, you must first leave that team before you can join this one."
      else
        if @team.users.include?(current_user)
          flash[:notice] = "You are already a member of this team!"
        else
          @team_member = OldTeamMember.new
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

  def leave
    unless @team.campaign.valid?
      flash[:notice] = "this campaign has ended"
      redirect_to dt_team_path(@team)
    end

    if (@team.leader == current_user)
      flash[:notice] = "You have created the team, you can not leave it"
      redirect_to dt_team_path(@team)
    end

    if (@team.users.include?(current_user))

      # Restrict participants from leaving the default team (thus, the campaign)
      if (@team == @team.campaign.default_team)
        flash[:notice] = "You can not leave the campaign"
	      redirect_to dt_team_path(@team)
      end

      # Deactivate the participant in their current team
      participant = @team.participant_for_user(current_user)
      participant.update_attribute :active, false

      # Put the participant in the default team
      if (default_participant = @team.campaign.default_team.participants.find_by_user_id(participant.user_id))
        default_participant.update_attribute :active, true
      else
        @team.campaign.default_team.participants.create :user_id => participant.user_id,
                                                        :short_name => participant.short_name,
                                                        :about_participant => participant.about_participant,
                                                        :active => true,
                                                        :pending => @team.campaign.default_team.require_authorization
      end
    else
      #print a notice that the user does not exist in the team
      flash[:notice] = "The user could not be found in the team"
    end

    flash[:notice] = "You have left the #{@team.name}"
    redirect_to dt_team_path(@team)
  end

  def approve
    @team = OldTeam.find(params[:id]) unless params[:id] == nil
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

      if(OldTeam.find_by_short_name_and_campaign_id(@short_name,params[:campaign_id]) != nil)
        @errors.push('That short name has already been used, short names must be unique to each campaign.')
      end
    else
      @errors.push('The short name may not contain any reserved characters such as ?')
    end
    [@errors, @short_name]
  end


  protected
  def access_denied
    if ['join', 'new', 'create'].include?(action_name) && !logged_in?
      flash[:notice] = "You must have an account to create a team in this campaign.  Log in below, or "+
      "<a href='/dt/signup'>click here</a> to create an account."
      respond_to do |accepts|
        accepts.html { redirect_to login_path and return }
      end
    elsif ['manage','edit'].include?(action_name) && !logged_in?
      flash[:notice] = "You must be logged in to manage your team profile or details. Please log in."
      respond_to do |accepts|
        accepts.html { redirect_to login_path and return }
      end
    end
    super
  end

  private
  def find_campaign
    @campaign = OldCampaign.find(params[:campaign_id]) unless params[:campaign_id].blank?
    @campaign = OldCampaign.find_by_short_name(params[:short_campaign_name]) unless params[:short_campaign_name].blank?

    if @campaign == nil
      @campaign = OldTeam.find(params[:id]).campaign unless params[:id] == nil
    end
    raise ActiveRecord::RecordNotFound unless @campaign
    @campaign
  end

  def find_team
    @team = OldTeam.find(params[:id]) unless params[:id].blank?
    @team = OldTeam.find_by_short_name(params[:short_name]) unless params[:short_name].blank?
    raise ActiveRecord::RecordNotFound unless @team
    @team
  end
end
