class Dt::AccountsController < DtApplicationController
  before_filter :login_required, :only => [ :show, :edit, :update ]
  helper "dt/places"
  
  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'new') unless logged_in? || User.count > 0
  end

  # GET /dt/accounts/1
  def show
    @user = User.find(params[:id], :include => [:user_transactions, :projects])
  end

  # GET /dt/accounts/new
  def new
    redirect_back_or_default(:action => 'index') if logged_in?
    @action_js = "dt/accounts"
    @user = User.new
  end

  # GET /dt/accounts/1;edit
  def edit
    redirect_to(:action => 'index') unless authorized?
    @action_js = "dt/accounts"
    @user = User.find(params[:id])
  end

  # POST /dt/accounts
  # POST /dt/accounts.xml
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @saved = @user.save
        session[:tmp_user] = @user.id
        flash[:notice] = 'Thanks for signing up! An activation email has been sent to your email address.'
        format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'index') }
        #format.js
        format.xml  { head :created, :location => dt_accounts_url }
      else
        @action_js = "dt/accounts"
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
    
    # password changing - requires the old password to be entered and correct
    if params[:old_password] && !current_user.authenticated?(params[:old_password])
      params[:old_password] = nil
      @user.errors.add('old_password', "was incorrect")
    end
    params[:user][:password] = nil if !params[:old_password]
    #params[:user][:password_confirmation] = nil if !params[:old_password]
    @saved = @user.update_attributes(params[:user])
    
    respond_to do |format|
      if @saved
        if @user.login_changed?
          flash[:notice] = 'A confirmation email has been sent to your email address.'
        else
          flash[:notice] = 'Account was successfully updated.'
        end
        format.html { redirect_to dt_accounts_url() }
        #format.js
        format.xml  { head :ok }
      else
        flash[:error] = "Couldn't change your password" 
        @action_js = "dt/accounts"
        format.html { render :action => "edit" }
        #format.js
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  def activate
    @user = User.find_by_activation_code(params[:id]) if params[:id]
    if @user and @user.activate
      self.current_user = @user
      session[:tmp_user] = nil
      flash[:notice] = "Your email address has been confirmed and your account is activated!"
    else
      flash[:notice] = "Account activation has failed. You may have followed an expired confirmation link, or have copied a link incorrectly. Please review your email and try again."
    end
    respond_to do |format|
        format.html { redirect_back_or_default(:controller => '/dt/accounts', :action => 'index') }
    end
  end
  
  def resend(user=nil)
    if !user
      user = User.find_by_id( logged_in? ? current_user : session[:tmp_user] )
    end
    DonortrustMailer.deliver_user_change_notification(user) if user && user.activation_code
    flash[:notice] = "We have resent the activation email to your login email address"
    redirect_to dt_accounts_url()
  end
  
  protected
  # protect the show/edit/update methods so you can only update/view your own record
  def authorized?(user = current_user())
    if ['show', 'edit', 'update'].include?(action_name)
       return false unless logged_in? && params[:id] && current_user.id == params[:id].to_i
    end
    return true
  end

  def access_denied
    if 'show' == action_name && logged_in?
      respond_to do |accepts|
        accepts.html { redirect_to( :controller => '/dt/accounts', :action => 'show', :id => current_user.id) }
      end
    else
      super
    end
  end
end
