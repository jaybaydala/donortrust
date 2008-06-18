class BusAdmin::DepositsController < ApplicationController
 
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  def new
    @users = User.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @deposit = AdminDeposit.new(params[:deposit])
    build_deposit
    Deposit.transaction do
      @saved = @deposit.save
    end
    if @saved
      flash[:notice] = "Successfully created the deposit."
      #send a notification to the donor, so that they are aware that their donation has been processed
      #by Christmas Future
      DonortrustMailer.deliver_us_deposit_notification(@deposit.user) if @deposit.user
    else
      flash[:error] = "Could not create the deposit (did you enter a valid dollar amount?)."
    end
    respond_to do |format|
      format.html { redirect_to new_deposit_url }
    end
  end
  
  private
  def build_deposit
    unless @deposit.user.nil?
      @deposit.first_name = @deposit.user.first_name
      @deposit.last_name = @deposit.user.last_name
      @deposit.address = @deposit.user.address
      @deposit.city = @deposit.user.city
      @deposit.province = @deposit.user.province
      @deposit.postal_code = @deposit.user.postal_code
      @deposit.country = @deposit.user.country
    end
  end
end