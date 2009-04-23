class Dt::ParticipantsController < DtApplicationController

  before_filter :find_team, :only => [:new, :create]
  before_filter :login_required, :except => [:show, :index]
  before_filter :is_authorized?, :only => [:update, :manage, :admin]
  include UploadSyncHelper
  after_filter :sync_uploads, :only => [:create, :update, :destroy]

  def show
    store_location

    @participant = Participant.find(params[:id]) unless params[:id] == nil

    if @participant == nil
      @participant = Participant.find_by_short_name(params[:short_name]) unless params[:short_name] == nil
    end

    @campaign = Campaign.find_by_short_name(params[:short_campaign_name]) unless params[:short_campaign_name] == nil
    @team = Team.find_by_short_name(params[:team_short_name]) unless params[:team_short_name] == nil

    if(@team != nil and @user != nil)
      @participant = Participant.find_by_user_id_and_team_id(@user.id,@team.id)
    elsif(@user != nil and @campaign != nil)
      for participant in @campaign.participants
        if participant.user == @user
          @participant = participant
        end
      end
    end

    if (@campaign == nil && @participant != nil)
      @campaign = @participant.team.campaign
    end

    if @participant == nil
      flash[:notice] = 'That campaign / participant could not be found'
      redirect_to dt_campaigns_path
    end
  end

  def new
    store_location
    @participant = Participant.new

    if (current_user == :false)
      @participant.user = User.new
    else
      # Make sure the user hasn't already signed up to this campaign
      current_user.campaigns.each do |c|

        if (c.id == @team.campaign.id)
          # This user has already signed up for this campaign
          existing_participant = Participant.find(:first, :conditions => [ "user_id = ? AND team_id = ?", current_user.id, @team.id ])
          if (existing_participant == nil)
            flash[:notice] = "You are already taking part in the " + @team.campaign.name + 
                             " campaign as a member of a different team, so you can't join " + @team.name + "."
            redirect_to dt_campaign_path(@team.campaign) 
          elsif (existing_participant.pending)
            flash[:notice] = "You have already applied to take part in the " + @team.campaign.name + 
                             " campaign as a member of " + @team.name + " but have not yet been approved."
            redirect_to dt_campaign_path(@team.campaign) 
          else
            flash[:notice] = "You are already taking part in the " + @team.campaign.name +
                             " campaign. This is your campaign page."
            redirect_to dt_participant_path(existing_participant) 
          end
        end

      end

      # This is the first time this user is signing up for this campaign
      @participant.user = current_user
    end
  end

  def create
    @participant = Participant.new(params[:participant])
    @participant.user = current_user
    @participant.team = @team

    if @team.require_authorization
      @participant.pending = true
    else
      @participant.pending = false
    end

    if @participant.save
      redirect_to dt_participant_path(@participant)
    else
      render :action => 'new'
    end
  end

  def validate_short_name_of
    @errors = Array.new
    @short_name = params[:participant_short_name]
    if @short_name != nil
      @short_name.downcase!

      if(@short_name =~ /\W/)
        @errors.push('You may only use Alphanumeric Characters, hyphens, and underscores. This also means no spaces.')
      end

      if(@short_name.length < 3 and @short_name.length != 0)
        @errors.push('The short name must be 3 characters or longer.')
      end

      participants_shortname_find = Participant.find_by_sql([
        "SELECT p.* FROM participants p INNER JOIN teams t INNER JOIN campaigns c " +
        "ON p.team_id = t.id AND t.campaign_id = c.id "+
        "WHERE p.short_name = ? AND c.id = ?",@short_name, params[:campaign_id]])

      if(participants_shortname_find != nil && !participants_shortname_find.empty? )
        @errors.push('That short name has already been used, short names must be unique to each campaign.')
      end
    else
      @errors.push('The short name may not contain any reserved characters such as ?')
    end
    [@errors, @short_name]
  end


  def update
    @participant = Participant.find(params[:id])
    if @participant.update_attributes(params[:participant])
      flash[:notice] = 'Page successfully updated.'
      redirect_to(manage_dt_participant_path(@participant))
    else
      render :action => "manage"
    end
  end

  def manage
    @participant = Participant.find(params[:id])
  end

  def admin
    @campaigns = Campaign.find_all_by_pending(false)
  end

  def index
    #@participants = Participant.paginate , :page => params[:page], :per_page => 20

    @participants = Participant.paginate_by_sql(["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ?", params[:campaign_id]], :page => params[:page], :per_page => 20) unless params[:campaign_id] == nil
    @participants = Participant.paginate_by_team_id(params[:team_id], :page => params[:page], :per_page => 20) unless params[:team_id] == nil

    @campaign = Campaign.find(params[:campaign_id]) unless params[:campaign_id] == nil
    if !@campaign
      @campaign = Team.find(params[:team_id]).campaign
    end
  end

  def destroy
    @participant = Participant.find(params[:id])
    @campaign = @participant.team.campaign
    @participant.destroy
    if params[:campaign_id] != nil
      redirect_to manage_dt_campaign(Campaign.find(params[:campaign_id]))
    elsif params[:team_id] != nil
      redirect_to manage_dt_campaign(Team.find(params[:team_id]))
    else
      redirect_to(dt_campaign_path(@campaign))
    end
  end

  def approve
    @participant = Participant.find(params[:id]) unless params[:id] == nil
    @team = @participant.team
    if @participant.approve!
      flash[:notice] = "#{@participant.name} approved!"
      redirect_to manage_dt_team_path(@team)
      # send email to participant when approved
      CampaignsMailer.deliver_participant_approved(@participant.campaign, @participant.team, @participant)
    else
      flash[:notice] = "There was an error approving that participant, please try again."
    end
  end

  # assign participant to generic team and approve
  def decline
    assign_participant_to_generic_team(params[:id])
    if @participant.approve!
      flash[:notice] = "#{@participant.name} assigned to #{@campaign.name} with with no team."
      redirect_to manage_dt_team_path(@team)
      # send email to participant when approved
      CampaignsMailer.deliver_participant_declined(@participant.campaign, @participant.team, @participant)
    else
      flash[:notice] = "There was an error declining that participant, please try again."
    end

  end

  protected
  def access_denied
    if ['join', 'new', 'create'].include?(action_name) && !logged_in?
      flash[:notice] = "You must have an account to join this campaign as a participant. Log in below, or "+
      "<a href='/dt/signup'>click here</a> to create an account."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    elsif ['manage'].include?(action_name) && !logged_in?
      flash[:notice] = "You must be logged in to manage your participant account.  Please log in."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    end
    super
  end


  private
  def find_team
    @team = Team.find(params[:team_id])
  end

  def is_authorized?
    @participant = Participant.find(params[:id])
    if @participant.user != current_user and not current_user.is_cf_admin?
      flash[:notice] = 'You are not authorized to see that page.'
      redirect_to dt_participant_path(@participant)
    end
  end

  private
  def assign_participant_to_generic_team(participant_id)
    @participant = Participant.find(participant_id) unless participant_id == nil
    @team = @participant.team
    @campaign = @team.campaign
    @participant.team = @campaign.generic_team
  end
end
