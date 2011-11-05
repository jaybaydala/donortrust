class Iend::TeamMembershipsController < DtApplicationController
  before_filter :require_user, :only => :create
  before_filter :restrict_to_owner, :only => :destroy

  def create
    @team_membership = TeamMembership.new(params[:team_membership])
    @team_membership.user = current_user
    if @team_membership.save
      flash[:notice] = "Welcome to the team"
      redirect_to iend_campaign_team_path(@team_membership.team.campaign, @team_membership.team)
    else
      render :controller => 'Iend/TeamMemberships', :action => :show, :team_id => @team_membership.team_id
    end
  end


  def destroy
    @team_membership.destroy
    flash[:notice] = "You have left the team"
    redirect_to iend_campaign_team_path(@team_membership.team.campaign, @team_membership.team)
  end

  protected
    def require_user
      if !logged_in?
        flash[:notice] = "Please login"
        redirect_to login_path
      end
    end

    def restrict_to_owner
      @team_membership = TeamMembership.find(params[:id])
      if @team_membership.user != current_user
        flash[:error] = "You do not have permission to do that"
        redirect_to iend_campaign_team_path(@team_membership.team.campaign, @team_membership.team) and return
      end
    end
end