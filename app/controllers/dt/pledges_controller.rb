class Dt::PledgesController < DtApplicationController
  include OrderHelper
  
  before_filter :find_participant

  def create
    @cart = find_cart
    @pledge = Pledge.new(params[:pledge])
    @deposit = Deposit.new
    @deposit.amount = @pledge.amount
    @deposit.user = @participant.user
    
    if @deposit.save
      @pledge.deposit = @deposit
      @pledge.participant = @participant
      if @pledge.save
        @cart.add_item(@deposit)
        redirect_to dt_participant_path(@participant)
      else
        render :action => "new"
      end
    else
      render :action => "new"
    end
  end

  def new
    @pledge = Pledge.new
  end
  
  private
  def find_participant
    @participant = Participant.find(params[:participant_id])
  end
end
