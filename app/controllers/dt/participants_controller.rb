class Dt::ParticipantsController < DtApplicationController

  before_filter :find_team, :only => [:new, :create]
  before_filter :login_required, :except => [:show, :index]
  before_filter :is_authorized?, :only => [:update, :manage, :admin]

  def show
    [@participant = Participant.find(params[:id]), @campaign = @participant.team.campaign]
    if @participant.private
      flash[:notice] = 'That user has requested that his campaign page remain private.'
      redirect_to dt_team_path(@participant.team)
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
