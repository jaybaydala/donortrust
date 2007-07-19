class Dt::AccountsController < DtApplicationController
  before_filter :login_required, :only => [ :edit, :update ]
  include DtAuthenticatedSystem

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'new') unless logged_in? || User.count > 0
  end

  # GET /dt/accounts/new
  def new
    redirect_back_or_default(:action => 'index') if logged_in?
    @user = User.new
  end

  # GET /dt/accounts/1;edit
  def edit
    redirect_to(:action => 'index') unless authorized?
    @user = User.find(params[:id])
  end

  # POST /dt/accounts
  # POST /dt/accounts.xml

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @saved = @user.save
        self.current_user = @user
        flash[:notice] = 'Thanks for signing up!'
        format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'index') }
        #format.js
        format.xml  { head :created, :location => dt_accounts_url }
      else
        format.html { render :action => "new" }
        #format.js
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # PUT /dt/accounts/1
  # PUT /dt/accounts/1.xml
  def update
    redirect_to(:action => 'edit', :id =>current_user.id) unless authorized?
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])

        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to dt_accounts_url() }
        #format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        #format.js
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /dt/accounts/1
  # DELETE /dt/accounts/1.xml
  #def destroy
  #  @user = User.find(params[:id])
  #  @user.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to dt_accounts_url }
  #    format.js
  #    format.xml  { head :ok }
  #  end
  #end


  # protect the new and create method for only admins
  def authorized?(user = current_user())
    if ['edit', 'update'].include?(action_name)
       return false unless logged_in? && params[:id] && current_user.id == params[:id].to_i
    end
    return true
  end

  def signin
    login
  end
  
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/dt/accounts', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/dt/accounts', :action => 'index')
  end
end
