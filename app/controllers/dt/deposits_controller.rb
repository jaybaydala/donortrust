require 'iats/iats_process.rb'
require 'pdf_proxy'
include PDFProxy
class Dt::DepositsController < DtApplicationController
  helper 'dt/places'
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
        if @deposit.country == 'Canada'
          gift_tax_receipt         
        end
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
  def ssl_required?
    true
  end

  def deposit_params
    card_exp = "#{params[:deposit][:expiry_month]}/#{params[:deposit][:expiry_year]}" if params[:deposit][:expiry_month] != nil && params[:deposit][:expiry_year] != nil
    deposit_params = params[:deposit]
    deposit_params.delete :expiry_month
    deposit_params.delete :expiry_year
    deposit_params[:card_expiry] = card_exp if deposit_params[:card_expiry] == nil
    deposit_params[:user_id] = current_user.id
    deposit_params
  end
  
  def gift_tax_receipt
    @deposit_tax_receipt = TaxReceipt.new( params[:tax_receipt] ) 
    if logged_in?
      @deposit_tax_receipt.user = current_user
    end
    @deposit_tax_receipt.first_name = @deposit.first_name
    @deposit_tax_receipt.last_name = @deposit.last_name
    @deposit_tax_receipt.address = @deposit.address
    @deposit_tax_receipt.city = @deposit.city    
    @deposit_tax_receipt.province = @deposit.province
    @deposit_tax_receipt.postal_code = @deposit.postal_code
    @deposit_tax_receipt.country = @deposit.country    
    @deposit_tax_receipt.email = current_user[:login]
    @deposit_tax_receipt.deposit_id = @deposit.id    
    @deposit_tax_receipt.save
    @deposit_tax_receipt.send_tax_receipt     
  end
end
