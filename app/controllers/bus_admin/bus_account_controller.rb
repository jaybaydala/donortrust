class BusAdmin::BusAccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie
  # say something nice, you goof!  something sweet.
  before_filter :login_required, :except => [:login, :signup]
   active_scaffold :bus_user do |config|
    config.label = "Users"
    config.columns = [:login, :email, :updated_at]
    
    config.create.columns[:login]
    #columns[:contacts].set_link('nested', :parameters => {:associations => :contacts})
    
    #config.action_links.add "Change Password", :action => 'change_password'
    #config.columns.set_link 'Change Password', :action => 'change_password'
    config.action_links.add 'change_password', :label => 'Change my password'
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
    
 def change_password
   #render :partial => "bus_admin/bus_account/password_form"
   active_scaffold :bus_user
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
        
       render_text "<h3>" + "Weak Password" + "</h3>"
        
      end
      if( !has_numbers && has_characters && !has_symbols)
        render_text "<h3>" + "Weak Password" + "</h3>"
      end      
      if( !has_numbers && has_characters && has_symbols)
        render_text "<h3>" + "Good Password" + "</h3>"
      end      
      if( has_numbers && !has_characters && !has_symbols)
        render_text "<h3>" + "Very Weak Password" + "</h3>"
      end      
      if( has_numbers && !has_characters && has_symbols)
        render_text "<h3>" + "Weak Password" + "</h3>"
      end      
      if( has_numbers && has_characters && !has_symbols)
        render_text "<h3>" + "Good Password" + "</h3>"
      end      
      if( has_numbers && has_characters && has_symbols)
        render_text "<h3>" + "Strong Password" + "</h3>"
      end      
    else
      render_text "<h3>" + "Needs more characters..." + "</h3>"
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
