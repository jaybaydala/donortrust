require 'iats/iats_process.rb'
require 'pdf_proxy'
include PDFProxy
class Dt::DepositsController < DtApplicationController
  helper 'dt/places'
  include IatsProcess
  include FundCf
  before_filter :login_required
  
  def initialize
    @page_title = "Deposit"
  end

  def new
    params[:deposit] = session[:deposit_params] if session[:deposit_params]
    @deposit = Deposit.new(deposit_params)
    @action_js = 'dt/giving'
  end
  
  def confirm
    session[:deposit_params] = params[:deposit] if params[:deposit]
    @deposit = Deposit.new( deposit_params )
    @action_js = 'dt/giving'

    @cf_investment = build_fund_cf_investment(@deposit)
    @total_amount = @deposit.amount + @cf_investment.amount if @cf_investment
    valid = cf_fund_investment_valid?(@deposit, @cf_investment)
  #  @deposit.amount += @cf_investment.amount if @cf_investment

    respond_to do |format|
      if valid
        format.html { render :action => "confirm" }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def create
    @deposit = Deposit.new( deposit_params )
    @action_js = 'dt/giving'
    iats = iats_payment(@deposit)
    @deposit.authorization_result = iats.authorization_result if iats.status == 1
    @deposit.user_ip_addr = request.remote_ip
    
    @cf_investment = build_fund_cf_investment(@deposit)
   # @deposit.amount += @cf_investment.amount if @cf_investment
    
    Deposit.transaction do
      if @cf_investment
        @saved = @deposit.save! && @cf_investment.save! if @deposit.authorization_result?
      else
        @saved = @deposit.save! if @deposit.authorization_result?
      end
      flash.now[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact.htm\">contact us</a>." if !@saved
    end
    
    respond_to do |format|
      if @saved
        if @deposit.country == 'Canada'
          create_tax_receipt         
        end
        session[:deposit_params] = nil
        flash[:notice] = "Your deposit was successful."
        format.html { redirect_to :controller => '/dt/accounts', :action => 'show', :id => current_user.id }
      else
        flash.now[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact.htm\">contact us</a>."
        format.html { render :action => "new" }
      end
    end
  end
   
  protected
  def ssl_required?
    true
  end

  def deposit_params
    card_exp = "#{params[:deposit][:expiry_month]}/#{params[:deposit][:expiry_year]}" if params[:deposit] && params[:deposit][:expiry_month] && params[:deposit][:expiry_year]
    deposit_params = {}
    deposit_params = deposit_params.merge(params[:deposit]) if params[:deposit]
    deposit_params.delete(:expiry_month) if deposit_params.key?(:expiry_month)
    deposit_params.delete(:expiry_year) if deposit_params.key?(:expiry_year)
    deposit_params.delete("expiry_month") if deposit_params.key?("expiry_month")
    deposit_params.delete("expiry_year") if deposit_params.key?("expiry_year")
    
    if deposit_params.key?("card_expiry")
      if card_exp.nil? || card_exp.blank?
        card_exp = deposit_params["card_expiry"]
        deposit_params.delete("card_expiry")
      end
    end
    
    deposit_params[:card_expiry] = card_exp if deposit_params[:card_expiry].nil?
    deposit_params[:user_id] = current_user.id
    deposit_params
  end
  
  def create_tax_receipt
    @tax_receipt = TaxReceipt.new( params[:tax_receipt] ) 
    if logged_in?
      @tax_receipt.user = current_user
    end
    @tax_receipt.first_name = @deposit.first_name
    @tax_receipt.last_name = @deposit.last_name
    @tax_receipt.address = @deposit.address
    @tax_receipt.city = @deposit.city    
    @tax_receipt.province = @deposit.province
    @tax_receipt.postal_code = @deposit.postal_code
    @tax_receipt.country = @deposit.country    
    @tax_receipt.email = current_user[:login]
    @tax_receipt.deposit_id = @deposit.id    
    @tax_receipt.save
  end
end
