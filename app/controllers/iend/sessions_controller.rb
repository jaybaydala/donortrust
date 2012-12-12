class Iend::SessionsController < DtApplicationController

  def show
    respond_to do |format|
      format.html {
        redirect_to(iend_users_path) and return unless logged_in?
        redirect_to(iend_user_path(current_user))
      }
    end
  end

  def new
    respond_to do |format|
      format.html {
        redirect_back_or_default(iend_user_path(current_user)) if logged_in?
        render :action => :new, :layout => false if request.xhr?
      }
    end
  end

  #MP - Dec 14, 2007
  #if the user is logged in, direct them to the GroundSpring site,
  #if not, force them to log in or create an account and then log in.
  def request_us_tax_receipt
    if logged_in?
      respond_to do |format|
        format.html {redirect_to GROUNDSPRING_URL}
      end
    else
      #if the user is NOT logged in, capture their desire to
      #request a US tax receipt as a session variable and
      #redirect them to the login page.
      requires_us_tax_receipt(true)
      respond_to do |format|
        format.html {redirect_to login_url}
      end
    end
  end

  def create
    return unless request.post?
    self.current_user = User.authenticate(params[:user][:login], params[:user][:password])
    respond_to do |format|
      if logged_in?
        current_user.update_attribute(:last_logged_in_at, Time.now)
        session[:tmp_user] = nil
         if session[:omniauth]
           current_user.apply_omniauth(session[:omniauth])
           current_user.save # save the authentication and profile updates
           session[:omniauth] = nil
         end
        if params[:user][:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        cookies[:login_id] = self.current_user.id.to_s
        cookies[:login_name] = self.current_user.full_name
        if current_user.change_password?
          flash[:notice] = "Please change your password to something you'll remember"
          format.html { redirect_to edit_iend_user_path(current_user) }
        else
          #MP - Dec 14, 2007
          #Added to support the us tax receipt functionality
          #If the user has indicated that they want a US tax
          #receipt, the session variable should be set to false,
          #and the user redirected to the GroundSpring page
          unless requires_us_tax_receipt?
            flash[:notice] = "Logged in successfully"
            format.html { redirect_back_or_default(home_path) }
          else
            #The user has indicated that they want a US tax receipt,
            #so clear out the session variable and
            #redirect them to SessionsController#request_us_tax_receipt
            requires_us_tax_receipt(false)
            format.html {redirect_to dt_request_us_tax_receipt_url}
          end
        end
      else
        u = User.find(:first, :conditions => {:login => params[:user][:login] })
        if u && u.authenticated?(params[:user][:password])
          @activated = false
          session[:tmp_user] = u.id
          flash.now[:error] = "A confirmation email has been sent to your login email address"
        # elsif u && u.expired?
        #   @expired = true
        #   flash.now[:error] = "Your account has expired."
        else
          flash.now[:error] = "Either your username or password are incorrect"
        end
        format.html { render :action => 'new' }
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete :login_id
    cookies.delete :login_name
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/dt/home', :action => 'index')
  end

  protected
  def ssl_required?
    true
  end

  # if they're being redirected back to a "false" account, put the proper account id in
  def redirect_back_or_default_with_account(default)
    if logged_in? && session[:return_to] =~ /^\/dt\/accounts\/false/
      session[:return_to].sub!(/^\/dt\/accounts\/false/, "/dt/accounts/#{current_user.id}")
    end
    redirect_back_or_default_without_account(default)
  end
  alias_method_chain :redirect_back_or_default, :account
end
