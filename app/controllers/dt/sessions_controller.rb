class Dt::SessionsController < ApplicationController
 
  def show
    respond_to do |format|
      format.html {
        redirect_to(dt_accounts_path) and return unless logged_in?
        redirect_to(dt_account_path(current_user))
      }
    end
  end
  
  def new
    @page_title = "Login"
    respond_to do |format|
      format.html { redirect_back_or_default(dt_account_path(current_user)) if logged_in? }
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
        format.html {redirect_to dt_login_url}
      end
    end
  end
  
  def create
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    respond_to do |format|
      if logged_in?
        current_user.update_attributes(:last_logged_in_at => Time.now)
        session[:tmp_user] = nil
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        cookies[:dt_login_id] = self.current_user.id.to_s
        cookies[:dt_login_name] = self.current_user.name
        if current_user.change_password?
          flash[:notice] = "Please change your password to something you'll remember"
          format.html { redirect_to dt_edit_account_path(current_user) }
        else
          #MP - Dec 14, 2007
          #Added to support the us tax receipt functionality
          #If the user has indicated that they want a US tax 
          #receipt, the session variable should be set to false,
          #and the user redirected to the GroundSpring page
          unless requires_us_tax_receipt?
            flash[:notice] = "Logged in successfully"
            format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'index') }
          else
            #The user has indicated that they want a US tax receipt,
            #so clear out the session variable and
            #redirect them to SessionsController#request_us_tax_receipt
            requires_us_tax_receipt(false)
            format.html {redirect_to dt_request_us_tax_receipt_url}
          end
        end
      else
        u = User.find(:first, :conditions => {:login => params[:login] })
        if u && u.authenticated?(params[:password])
          @activated = false
          session[:tmp_user] = u.id
          flash.now[:error] = "A confirmation email has been sent to your login email address"
        elsif u && u.expired?
          @expired = true
          flash.now[:error] = "Your account has expired."
        else
          flash.now[:error] = "Either your username or password are incorrect"
        end
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete :dt_login_id
    cookies.delete :dt_login_name
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/dt/accounts', :action => 'index')
  end
end
