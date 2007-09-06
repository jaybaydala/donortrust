class Dt::DepositsController < DtApplicationController
  before_filter :login_required
  
  # Disallow the confirm action being called unless it's using the 
  # :post method and contains both the "user" and "deposit" hashes
  # in the params. Will be redirected back to new if verification fails
  #verify :params => [ "user", "deposit" ], :method => :post, 
  #       :only => :confirm, 
  #       :add_flash => { "error" => "Please confirm the below information" }, 
  #       :redirect_to => :new

  def index 
    redirect_to(:action => 'new') if logged_in?
  end
  
  def new
    @user = current_user
    @deposit = Deposit.new
  end
  
  def create
    @test_mode = ENV["RAILS_ENV"] == 'production' ? false : true
    @deposit = Deposit.new( deposit_attributes )
    iats_deposit(@deposit)
    respond_to do |format|
      if @saved = @deposit.save
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
    redirect_to(:action => "new") and return if !params[:deposit][:amount] || !params[:deposit][:credit_card] || !params[:deposit][:expiry_month] || !params[:deposit][:expiry_year]
    @user = current_user
    @user.update_attributes( params[:user] ) if params[:user]
    @deposit = Deposit.new( deposit_attributes )
    respond_to do |format|
      if @deposit.valid?
        format.html { render :action => "confirm" }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  protected
  def deposit_attributes
    card_exp = "#{params[:deposit][:expiry_month]}/#{params[:deposit][:expiry_year]}" if params[:deposit][:expiry_month] && params[:deposit][:expiry_year]
    card_exp = params[:deposit][:card_expiry] if params[:deposit][:card_expiry]
    attributes = {
      :user_id => current_user.id, 
      :user_hash => current_user,
      :amount => params[:deposit][:amount],
      :credit_card => params[:deposit][:credit_card],
      :card_expiry => card_exp
      }
  end
  
  def iats_deposit(deposit)
    require 'iats/iats_link'
    iats = IatsLink.new
    iats.test_mode = @test_mode
    iats.agent_code = ''
    iats.password = ''
    # When taking CDN$, can we only have cardholder_name or will it work with the US$ info?
    # if it would work, just use it all the time...
    #iats.cardholder_name = "#{current_user.first_name} #{current_user.last_name}"
    # When taking US$, you must remove cardholder_name and add the following before calling process_credit_card:
    iats.first_name = deposit[:user_hash].first_name
    iats.last_name = deposit[:user_hash].last_name
    iats.street_address = deposit[:user_hash].address
    iats.city = deposit[:user_hash].city
    iats.state = deposit[:user_hash].province
    iats.zip_code = deposit[:user_hash].postal_code

    iats.card_number = deposit[:credit_card]
    iats.card_expiry = deposit[:card_expiry]
    iats.dollar_amount = deposit[:amount]
    
    # kill this line when we get our IATS agent_code & password
    deposit.authorization_result = "1234" if @test_mode == true
    return if @test_mode == true
    iats.process_credit_card
    if iats.status == 1
      deposit.authorization_result = iats.authorization_result
    else
      deposit.errors.add("authorization_result", "was unable to authorize credit card")
    end
  end
end

