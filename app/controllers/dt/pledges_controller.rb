class Dt::PledgesController < DtApplicationController
  include OrderHelper

  def create
    @cart = find_cart
    @pledge = Pledge.new(params[:pledge])
    @pledge.user = current_user if logged_in?
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
    if @participant && (@participant.pending || @participant.team.pending || @participant.team.campaign.pending)
      flash[:notice] = "#{@participant.name}, or the team or campaign they are participating in has not been approved yet.  You can sponsor #{@participant.name} once they have been approved."
      redirect_to dt_participant_path(@participant)
    end

    @team = Team.find(params[:team_id]) unless params[:team_id] == nil
    if @team && (@team.pending || @team.campaign.pending)
      flash[:notice] = "#{@team.name}, or the campaign it is participating in has not been approved yet.  You can sponsor team #{@team.name} they have been approved."
      redirect_to dt_team_path(@team)
    end

    @campaign = Campaign.find(params[:campaign_id]) unless  params[:campaign_id] == nil
    if @campaign && @campaign.pending
      flash[:notice] = "#{@campaign.name} has not been approved yet. You can sponsor team #{@campaign.name} they have been approved."
      redirect_to dt_campaign_path(@campaign)
    end

    @pledge = Pledge.new
  end

end
