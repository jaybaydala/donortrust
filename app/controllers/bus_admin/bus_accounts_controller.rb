class BusAdmin::BusAccountsController < ApplicationController
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  require_role [:admin, :cfadmin, :partner, :superpartner], :for_all_except => [:login, :signup]

  # say something nice, you goof!  something sweet.
  def index
    @page_title = 'Users'
    @busAccounts = BusAccount.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def show
    begin
      @busAccount = BusAccount.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @busAccount.login
    respond_to do |format|
      format.html
    end
  end

  def login
    return unless request.post?
    self.current_busaccount = BusAccount.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_busaccount.remember_me
        cookies[:auth_token] = { :value => self.current_busaccount.remember_token , :expires => self.current_busaccount.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/bus_admin/bus_accounts', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
  end
  
  def signup
    @bus_account = BusAccount.new(params[:bus_account])
    return unless request.post?
    @bus_account.save!
    self.current_busaccount = @bus_account
    redirect_back_or_default(:controller => '/bus_admin/bus_accounts', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_busaccount.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/bus_admin/bus_accounts', :action => 'index')
  end
end
