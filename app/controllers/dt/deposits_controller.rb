class Dt::DepositsController < DtApplicationController
  before_filter :login_required

  def new
    @deposit = Deposit.new
  end
  
  def create
    @test_mode = ENV["RAILS_ENV"] == 'production' ? false : true
    @deposit = Deposit.new( deposit_params )
    iats = iats_process(@deposit)
    @deposit.authorization_result = iats.authorization_result if iats.status == 1
    
    respond_to do |format|
      if @deposit.authorization_result != nil && @saved = @deposit.save
        flash[:notice] = "Your deposit was successful."
        format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'show', :id => current_user.id ) }
        #format.js
        format.xml  { head :created, :location => dt_accounts_url }
      else
        flash[:error] = "There was an error processing your credit card. If this issue continues, please <a href=\"/contact.htm\">contact us</a>."
        format.html { render :action => "new" }
        #format.js
        format.xml  { render :xml => @user.errors.to_xml }
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

  def iats_process( record )
    require 'iats/iats_link'
    iats = IatsLink.new
    iats.test_mode = @test_mode
    iats.agent_code = '2CFK99'
    iats.password = 'K56487'
    # When taking CDN$, can we only have cardholder_name or will it work with the US$ info?
    # if it would work, just use it all the time...
    #iats.cardholder_name = "#{current_user.first_name} #{current_user.last_name}"
    # When taking US$, you must remove cardholder_name and add the following before calling process_credit_card:
    iats.first_name = record[:first_name]
    iats.last_name = record[:last_name]
    iats.street_address = record[:address]
    iats.city = record[:city]
    iats.state = record[:province]
    iats.zip_code = record[:postal_code]

    iats.card_number = record[:credit_card]
    iats.card_expiry = record[:card_expiry]
    iats.dollar_amount = record[:amount]
    
    if ENV["RAILS_ENV"] == 'test'
      iats.status = 1
      iats.authorization_result = 1234
    else
      iats.process_credit_card
    end
    iats
  end
end
