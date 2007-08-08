class BusAdmin::BusAccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie
  # say something nice, you goof!  something sweet.
  before_filter :login_required, :check_authorization, :except => [:login, :signup, :logout]
 
  active_scaffold :bus_user do |config|
    config.label = "Users"     

   
    config.action_links.add 'reset_password', :label => 'Reset A Password', :parameters =>{:controller=>'bus_account', :action => 'reset_password'}
    config.list.columns.exclude [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :updated_at, :created_at]
    config.show.columns.exclude [:crypted_password, :salt, :remember_token, :remember_token_expires_at]
    config.create.columns.exclude [:crypted_password, :salt, :remember_token, :remember_token_expires_at]

#     await version 1.1
#    config.columns[:password].form_ui = :password
#    config.columns[:password_confirmation].form_ui = :password
    config.create.columns.add [:password, :password_confirmation]
    config.update.columns.exclude [:crypted_password, :salt, :remember_token, :remember_token_expires_at, :upadted_at, :created_at]
    list.sorting = {:login => 'ASC'}
  end
  
  def index
    render :template => 'bus_admin/bus_account/account_admin', :layout => true
  end
  
  def reset_password 
    render :partial => 'bus_admin/bus_account/reset_password'
  end
  
  def reset_password_now
    bus_user = BusUser.find(params[:bus_user][:id])
    temporary_password = params[:temporary_password]
    if bus_user.reset_pass(temporary_password)
      redirect_to('/bus_admin/index')
#      show_message_and_reset("Password sucessfully reset for " + bus_user.login.to_s, "info")
    else
      redirect_to('/bus_admin/index')
#      show_message_and_reset("An errored occured for user: " + bus_user.login.to_s, "error")
    end
    
  end
  
  def request_temporary_password
    render :text => "<dl><dt><label for='temporary_password'>Enter a temporary password:</label></dt><input autocomplete='off' class='text-input' id='temporary_password' name='temporary[password]' size='20' type='text' /></dl>"
    
  end
  
  def login
    if params[:login] != nil && params[:password] != nil
    self.current_bus_user = BusUser.authenticate(params[:login], params[:password])
     if logged_in?
      if params[:remember_me] == "1"
        self.current_bus_user.remember_me   
        cookies[:auth_token] = { :value => self.current_bus_user.remember_token , :expires => self.current_bus_user.remember_token_expires_at }
      end
        jumpto = session[:jumpto] || {:action => 'index'}
        session[:jumpto] = nil
        redirect_to('/bus_admin/home')
      
      session[:user] = self.current_bus_user
      flash[:notice] = "Logged in successfully"
     else
        
        redirect_to('/bus_admin/login')
        flash[:notice] = "Your password may be incorrect, or the specified user doesn't exist"
      end
    end
   
  end


#  def signup
#    if BusUser.new(params[:bus_user])
#    @bus_user = BusUser.new(params[:bus_user])
#      if @bus_user.save
#      #puts @bus_user.login
#      
#      @bus_user.save!
#      self.current_bus_user = @bus_user
#      
#      redirect_back_or_default(:controller => '/bus_admin/bus_account', :action => 'index')
#      flash[:notice] = "Thanks for signing up!"
#    end
#    end
#  end

  def signup
    @bus_user = BusUser.new(params[:bus_user])
    return unless request.method == :post
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
    
 def change_password
  render :partial => "bus_admin/bus_account/password_form"
    
 end
 
 def change_password_now  
   @current_pass = params[:current_user][:current_password]
   @bus_user = session[:user]
      if params[:current_user][:new_password] == params[:current_user][:confirm_password] 
        if inspect_password(@current_pass)
          if @bus_user.update_password(params[:current_user][:new_password],@current_pass)
            redirect_to :action => 'index'
            flash[:notice] = "Confirmed"
          else
           redirect_to :action => 'index'
            flash[:notice] = "Current password doesn't match"
          end
          else
            redirect_to :action => 'index'
            flash[:notice] = "Password must contain numbers, characters, and symbols only."
          end
        else
       redirect_to :action => 'index'
       flash[:notice] = "Passwords don't match"
      end  
 end
 
  
 def show_encryption
    @password = params[:new_password]
    characters = check_characters(@password)
    numbers = check_numbers(@password)
    symbols = check_symbols(@password)
    has_characters = characters.length > 0
    has_numbers = numbers.length > 0 
    has_symbols = symbols.length > 0
    if(@password.length >= 5)
      if( !has_numbers && !has_characters && !has_symbols)
       render_text ""
      end
      if( !has_numbers && !has_characters && has_symbols)
        
       render_text "<div id='weak'>" + "Weak Password" + "</div>"
        
      end
      if( !has_numbers && has_characters && !has_symbols)
        render_text "<div id='weak'>" + "Weak Password" + "</div>"
      end      
      if( !has_numbers && has_characters && has_symbols)
        render_text "<div id='good'>" + "Good Password" + "</div>"
      end      
      if( has_numbers && !has_characters && !has_symbols)
        render_text "<div id='very-weak'>" + "Very Weak Password" + "</div>"
      end      
      if( has_numbers && !has_characters && has_symbols)
        render_text "<div id='weak'>" + "Weak Password" + "</div>"
      end      
      if( has_numbers && has_characters && !has_symbols)
        render_text "<div id='good'>" + "Good Password" + "</div>"
      end      
      if( has_numbers && has_characters && has_symbols)
        render_text "<div id='strong'>" + "Strong Password" + "</div>"
      end      
    else
      render_text "<div id='needs-more'>" + "Needs more characters..." + "</div>"
    end
  end
  
  def check_characters(password)
    return password.scan(/[a-z]|[A-Z]/)  
  end
  
  def check_numbers(password)
    return password.scan(/[0-9]/)
  end
  
  def check_symbols(password)
    return password.scan(/[\#,\$,\%,\^,\&,\*,\_,\~]/)
  end
  
  def inspect_password(password)
   return true
  end

end
