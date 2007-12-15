class Dt::SessionsController < DtApplicationController
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
  
  def create
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    respond_to do |format|
      if logged_in?
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
          flash[:notice] = "Logged in successfully"
          format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'index') }
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
