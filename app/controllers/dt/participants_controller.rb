class Dt::ParticipantsController < DtApplicationController

  before_filter :find_team, :only => [:new, :create]
  before_filter :login_required, :except => [:show, :index]
  before_filter :is_authorized?, :only => [:update, :manage, :admin]

  def show
    @participant = Participant.find(params[:id]) unless params[:id] == nil
    @campaign = Campaign.find_by_short_name(params[:short_campaign_name]) unless params[:short_campaign_name] == nil
    @user = User.find_by_display_name(params[:display_name]) unless params[:display_name] == nil
    @team = Team.find_by_short_name(params[:team_short_name]) unless params[:team_short_name] == nil
    if(@team != nil and @user != nil)
      @participant = Participant.find_by_user_id_and_team_id(@user.id,@team.id)
    else
      if(@user != nil and @campaign != nil)
        for pariticpant in @campaign.participants
          if pariticpant.user == @user
            @participant = pariticpant
          end
        end
      end
    end
    if @campaign == nil
      @campaign = @participant.team.campaign
    end
    
    if @participant == nil
      flash[:notice] = 'That campaign / participant could not be found'
      redirect_to dt_campaigns_path
    end
  end
  
  def new
    @participant = Participant.new
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
    @participants = Participant.find(:all)
    @participants = Campaign.find(params[:campaign_id]).participants unless params[:campaign_id] == nil
    @participants = Team.find(params[:team_id]).participants unless params[:team_id] == nil
    
  end
  
  def destroy
    @participant = Participant.find(params[:id])
    @particiapnt.destroy
    if params[:campaign_id] != nil
      redirect_to manage_dt_campaign(Campaign.find(params[:campaign_id]))
    else
      if params[:team_id] != nil
        redirect_to manage_dt_campaign(Team.find(params[:team_id]))
      end
    end
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
end
