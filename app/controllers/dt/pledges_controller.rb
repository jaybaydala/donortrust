class Dt::PledgesController < DtApplicationController
  include OrderHelper

  def create_backup
    @cart = find_cart
    @pledge = Pledge.new(params[:pledge])
    @pledge.user = current_user if logged_in?
    @pledge.paid = false

    #decide what type of pledge it is
    #this is very important so that records are propperly tied as people move
    #around
    if(params[:participant_id] != nil)
      @participant = Participant.find(params[:participant_id])
      @pledge.participant = @participant

    elsif(params[:team_id] != nil)
      @team = Team.find(params[:team_id])
      @pledge.team = @team

    elsif(params[:campaign_id] != nil)
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


  def create
    @pledge = Pledge.new(params[:pledge])
    @pledge.user = current_user if logged_in?

    error_redirect_path = ""

    #decide what type of pledge it is and only fill in the appropriate field!
    #this is very important so that records are propperly tied as people move
    #around
    if(params[:participant_id] != nil)
      @participant = Participant.find(params[:participant_id])
      @pledge.participant = @participant
      error_redirect_path = new_dt_participant_pledge_path(@participant)

    elsif(params[:team_id] != nil)
      @team = Team.find(params[:team_id])
      @pledge.team = @team
      error_redirect_path = new_dt_team_pledge_path(@team)

    elsif(params[:campaign_id] != nil)
      @campaign = Campaign.find(params[:campaign_id])
      @pledge.campaign = @campaign
      error_redirect_path = new_dt_campaign_pledge_path(@campaign)
    end

    @valid = @pledge.valid?

    respond_to do |format|
      if @valid
        session[:pledge_params] = nil
        @cart = find_cart
        @cart.add_item(@pledge)
        flash[:notice] = "Your Pledge has been added to your cart."
        format.html { redirect_to dt_cart_path }
      else
        flash.now[:error] = "There was a problem adding the Pledge to your cart. Please review your information and try again."
        format.html { redirect_to error_redirect_path }
      end
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
    session[:return_to] = new_dt_participant_pledge_path(@participant)
    @pledge = Pledge.new
  end

end
