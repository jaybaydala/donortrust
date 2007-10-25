require 'iats/iats_process.rb'
class Dt::DepositsController < DtApplicationController
  include IatsProcess
  before_filter :login_required

  def new
    @deposit = Deposit.new
  end
  
  def create
    @deposit = Deposit.new( deposit_params )
    iats = iats_payment(@deposit)
    @deposit.authorization_result = iats.authorization_result if iats.status == 1
    @deposit.user_ip_addr = request.remote_ip
    
    respond_to do |format|
      if @deposit.authorization_result != nil && @saved = @deposit.save
        flash[:notice] = "Your deposit was successful."
        format.html { redirect_to :controller => '/dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash.now[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact.htm\">contact us</a>."
        format.html { render :action => "new" }
      end
    end
  end
  
  def confirm
    @deposit = Deposit.new( deposit_params )
    respond_to do |format|
      if @deposit.valid?
        format.html { render :action => "confirm" }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  protected
  def deposit_params
    card_exp = "#{params[:deposit][:expiry_month]}/#{params[:deposit][:expiry_year]}" if params[:deposit][:expiry_month] != nil && params[:deposit][:expiry_year] != nil
    deposit_params = params[:deposit]
    deposit_params.delete :expiry_month
    deposit_params.delete :expiry_year
    deposit_params[:card_expiry] = card_exp if deposit_params[:card_expiry] == nil
    deposit_params[:user_id] = current_user.id
    deposit_params
  end
end
