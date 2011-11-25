class Iend::CampaignDonationsController < DtApplicationController
  layout "campaigns"
  before_filter :load_campaign
  before_filter :find_cart
  include OrderHelper

  def new
    @campaign_donation = @campaign.campaign_donations.build(params[:campaign_donation])
    if !@campaign_donation.participant_id
      @campaign_donation.participant_id = @campaign.participants.find(:first, :conditions => {:user_id => @campaign.user_id}).id
    end
  end

  def create
    @campaign_donation = CampaignDonation.new( params[:campaign_donation] )
    @campaign_donation.user_id = current_user.id if logged_in?
    @campaign_donation.user_ip_addr = request.remote_ip

    @valid = @campaign_donation.valid?
    @cart.add_item(@campaign_donation) if @campaign_donation

    respond_to do |format|
      if @valid
        flash[:notice] = "Your Donation has been added to your cart."
        format.html { redirect_to dt_cart_path }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  protected
    def load_campaign
      @campaign = Campaign.find(params[:campaign_id])
      if !@campaign
        redirect_to iend_campaigns_path
      end
    end

end