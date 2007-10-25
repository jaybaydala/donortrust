class Dt::SessionsController < DtApplicationController
  def new
    redirect_back_or_default(dt_account_path(current_user)) if logged_in?
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
        flash[:notice] = "Logged in successfully"
        cookies[:dt_login] = self.current_user.id.to_s
        format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'index') }
      else
        u = User.find(:first, :conditions => {:login => params[:login] })
        if u && u.authenticated?(params[:password])
          @activated = false
          session[:tmp_user] = u.id
          flash[:error] = "A confirmation email has been sent to your login email address"
        elsif u && u.expired?
          @expired = true
          flash[:error] = "Your account has expired."
        else
          flash[:error] = "Either your username or password are incorrect"
        end
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    cookies.delete :dt_login
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/dt/accounts', :action => 'index')
  end
end
