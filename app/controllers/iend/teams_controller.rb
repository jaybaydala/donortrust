class Iend::TeamsController < DtApplicationController
  before_filter :require_user, :only => [ :new, :create ]
  before_filter :restrict_to_owner, :only => [ :edit, :update, :destroy ]
  layout "campaigns"

  def index
    @teams = Team.all
  end

  def show
    @team = Team.find(params[:id])
    @user = current_user
  end

  def new
    @team = Team.new(params[:team])
    @team.campaign = Campaign.find(params[:campaign_id])
  end

  def create
    @team = Team.new(params[:team])
    @team.campaign = Campaign.find(params[:campaign_id])
    @team.user = current_user
    if @team.save
      flash[:notice] = "Your new team was created"
      redirect_to iend_campaign_team_path(@team.campaign, @team)
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @team.update_attributes(params[:team])
      flash[:notice] = "Your changes have been saved"
      redirect_to iend_campaign_team_path(@team.campaign, @team)
    else
      render :edit
    end
  end

  def destroy
    @team.destroy
    flash[:notice] = "Your team was removed"
    redirect_to iend_teams_path
  end

  protected
    def require_user
      if !logged_in?
        flash[:notice] = "Please login"
        redirect_to login_path
      end
    end

    def restrict_to_owner
      @team = Team.find(params[:id])
      if @team.user != current_user
        flash[:error] = "You do not have permission to do that"
        redirect_to iend_team_path(@team.campaign, @team) and return
      end
    end
end