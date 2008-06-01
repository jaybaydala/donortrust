require 'iats/iats_process.rb'
require 'pdf_proxy'
include PDFProxy
class Dt::DepositsController < ApplicationController
  helper 'dt/places'
  include IatsProcess
  include FundCf
  before_filter :login_required
  
  #helper for testing purposes since I couldn't figure out
  #how to determine in the tests whether a certain layout was being used
  attr_accessor :using_us_layout
  
  CANADA = 'canada'
  
  def initialize
    super
    @page_title = "Deposit"
  end

  def new
    self.using_us_layout = false
    params[:deposit] = session[:deposit_params] if session[:deposit_params]
    @deposit = Deposit.new(deposit_params)
    @action_js = 'dt/giving'
    
    #MP Dec 14, 2007 - In order to support US donations, this was added to switch out the
    #layout of the Gift page. If the user's country is nil or not Canada,
    #use the layout that allows for US donations.
    if logged_in?
      unless current_user.in_country?(CANADA)
        self.using_us_layout = true
        render :layout => 'us_receipt_layout'
      end
    end
  end
  
  def confirm
    session[:deposit_params] = params[:deposit] if params[:deposit]
    @deposit = Deposit.new( deposit_params )
    @action_js = 'dt/giving'

    @cf_investment = build_fund_cf_investment(@deposit)
    @total_amount = @deposit.amount + @cf_investment.amount if @cf_investment
    valid = cf_fund_investment_valid?(@deposit, @cf_investment)

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
    
    Deposit.transaction do
      if @cf_investment
        @deposit.amount += @cf_investment.amount if @cf_investment # add to the total deposit amount
        @saved = @deposit.save! && @cf_investment.save! if @deposit.authorization_result?
        @deposit.amount -= @cf_investment.amount unless @saved # remove it if we're unsuccessful so we don't double-charge when they go back to confirm
      else
        @saved = @deposit.save! if @deposit.authorization_result?
      end
      flash.now[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact.htm\">contact us</a>." if !@saved
    end
    
    respond_to do |format|
      if @saved
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
    deposit_params = {}
    deposit_params = deposit_params.merge(params[:deposit]) if params[:deposit]
    deposit_params[:user_id] = current_user.id
    deposit_params
  end
end
