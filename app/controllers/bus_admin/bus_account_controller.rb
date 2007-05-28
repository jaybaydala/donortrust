class BusAdmin::BusAccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  # say something nice, you goof!  something sweet.
   active_scaffold :bus_user do |config|
    config.label = "Users"
    config.columns = [:login, :email, :updated_at]
    config.create.columns = [:login, :email, :password, :password_confirmation]
    config.nested.add_link "Change Password", [:change_password]
    list.columns.exclude [:crypted_password, :salt, :remember_token, :remember_token_expires_at]
    list.sorting = {:login => 'ASC'}
    
  end
    
  def login
    return unless request.post?
    self.current_bus_user = BusUser.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_bus_user.remember_me
        cookies[:auth_token] = { :value => self.current_bus_user.remember_token , :expires => self.current_bus_user.remember_token_expires_at }
      end
        jumpto = session[:jumpto] || {:action => 'index'}
        session[:jumpto] = nil
        redirect_to(jumpto)
      
      session[:user] = self.current_bus_user
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @bus_user = BusUser.new(params[:bus_user])
    puts @bus_user.login
    return unless request.post?
    @bus_user.save!
    self.current_bus_user = @bus_user
    
    redirect_back_or_default(:controller => '/bus_admin/bus_account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_bus_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/bus_admin/bus_account', :action => 'login')
  end
  


end
