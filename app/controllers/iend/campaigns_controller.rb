class Iend::CampaignsController < DtApplicationController
  before_filter :require_user, :only => [ :new, :create ]
  before_filter :restrict_to_owner, :only => [ :edit, :update, :destroy ]
  layout "campaigns"

  def index
    @campaigns = Campaign.all
  end

  def show
    @campaign = Campaign.find(params[:id])
    @user = current_user
  end

  def new
    @campaign = Campaign.new(params[:campaign])
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    @campaign.user = current_user
    if @campaign.save
      flash[:notice] = "Your new campaign was created"
      redirect_to iend_campaign_path(@campaign)
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @campaign.update_attributes(params[:campaign])
      flash[:notice] = "Your changes have been saved"
      redirect_to iend_campaign_path(@campaign)
    else
      render :edit
    end
  end

  def destroy
    @campaign.destroy
    flash[:notice] = "Your campaign was removed"
    redirect_to iend_campaigns_path
  end

  protected
    def require_user
      if !logged_in?
        flash[:notice] = "Please login"
        redirect_to login_path
      end
    end

    def restrict_to_owner
      @campaign = Campaign.find(params[:id])
      if @campaign.user != current_user
        flash[:error] = "You do not have permission to do that"
        redirect_to iend_campaign_path(@campaign) and return
      end
    end
end