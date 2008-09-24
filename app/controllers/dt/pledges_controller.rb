class Dt::PledgesController < DtApplicationController
  include OrderHelper
  
  def create
    @cart = find_cart
    @pledge = Pledge.new(params[:pledge])
    @pledge.paid = false
    if(params[:participant_id] != nil)
      @participant = Participant.find(params[:participant_id])
      @pledge.participant = @participant
      @pledge.team = @participant.team
      @pledge.campaign = @participant.team.campaign
    end
    
    if(params[:team_id] != nil)
      @team = Team.find(params[:team_id])
      @pledge.team = @team
      @pledge.campaign = @team.campaign
    end
    
    if(params[:campaign_id] != nil)
      @campaign = Campaign.find(params[:campaign_id])
      @pledge.campaign = @campaign
    end
    
    if @pledge.save
      @cart.add_item(@pledge)
      redirect_to dt_cart_path
    else
      render :action => "new"
    end
  end

  def new
    @participant = Participant.find(params[:participant_id]) unless  params[:participant_id] == nil
    @team = Team.find(params[:team_id]) unless  params[:teamn_id] == nil
    @campaign = Campaign.find(params[:campaign_id]) unless  params[:campaign_id] == nil
    @pledge = Pledge.new
  end
  
  
  
end
