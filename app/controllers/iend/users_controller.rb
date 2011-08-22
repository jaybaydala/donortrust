class Iend::UsersController < DtApplicationController
  before_filter :restrict_no_user, :only => [ :new, :create ]
  before_filter :restrict_current_user, :only => [ :edit, :update, :edit_password ]
  helper "dt/places"
  
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
      render :action => 'new_via_authentication' and return
    end
  end

  def create
    @user = User.new(params[:user])
    @user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    @saved = @user.save
    respond_to do |format|
      if @saved
        session[:omniauth] = nil
        session[:tmp_user] = @user.id
        self.current_user = @user
        flash[:notice] = "Signed in successfully."
        format.html { redirect_to(dt_give_path) }
      else
        format.html { render :action => (session[:omniauth] ? 'new_via_authentication' : 'new') }
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:current_password].present?
      params[:user][:password] = nil unless current_user.authenticated?(params[:user][:current_password])
    else
      params[:user][:password] = nil unless params[:user][:current_password].present?
    end
    @user.change_password = false
    @saved = @user.update_attributes(params[:user])
    respond_to do |format|
      if @saved
        flash[:notice] = if params[:user][:current_user].present?
          'Your new password was saved.'
        else
          'Your account was successfully updated.'
        end
        format.html { redirect_to [:iend, current_user] }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def edit_password
    @user = User.find(params[:id])
  end

  protected
    def restrict_no_user
      redirect_to([:iend, current_user]) if logged_in?
    end

    def restrict_current_user
      redirect_to(logged_in? ? iend_user_path(current_user) : iend_path) unless params[:id].to_i == current_user.id
    end
end