class Dt::ParticipantsController < DtApplicationController

  before_filter :find_team, :only => [:new, :create]

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
  
  def manage
    @participant = Participant.find(params[:id])
  end
  
  def admin
    @campaigns = Campaign.find_all_by_pending(false)
  end
  
  private
  def find_team
    @team = Team.find(params[:team_id])
  end
end
