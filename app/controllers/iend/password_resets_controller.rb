class Iend::PasswordResetsController < DtApplicationController
  def new
  end

  def create
    @user = User.find_by_login(params[:password_reset][:login]) if params[:password_reset] && params[:password_reset][:login]
    if @user
      @user.password = User.generate_password
      @user.password_confirmation = @user.password
      @user.change_password = true
      saved = @user.save
      DonortrustMailer.deliver_user_password_reset(@user) if saved
      flash[:notice] = "We have reset your password and sent it to your login email address" if saved
    end
    respond_to do |format|
      format.html {
        redirect_to login_path and return if @user && saved
        flash[:error] = "We could not find that login. Did you try your email address?"
        render :action => 'new'
      }
    end
    
  end
end