class Iend::ParticipantsController < DtApplicationController
  before_filter :require_user, :only => :create
  before_filter :restrict_to_owner, :only => :destroy

  def create
    @participant = Participant.new
    @participant.campaign = Campaign.find(params[:campaign_id])
    @participant.user = current_user
    if @participant.save
      flash[:notice] = "Welcome to the campaign"
      redirect_to iend_campaign_path(@participant.campaign)
    else
      render :controller => 'Iend/Campaigns', :action => :show, :campaign_id => params[:campaign_id]
    end
  end


  def destroy
    @participant.destroy
    flash[:notice] = "You have left the campaign"
    redirect_to iend_campaign_path(@participant.campaign)
  end

  protected
    def require_user
      if !logged_in?
        flash[:notice] = "Please login"
        redirect_to login_path
      end
    end

    def restrict_to_owner
      @participant = Participant.find(params[:id])
      if @participant.user != current_user
        flash[:error] = "You do not have permission to do that"
        redirect_to iend_campaign_path(@participant.campaign) and return
      end
    end
end