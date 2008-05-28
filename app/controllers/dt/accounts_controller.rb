class Dt::AccountsController < DtApplicationController
  before_filter :login_required, :only => [ :show, :edit, :update ]
  helper "dt/places"
  
  def initialize
    @page_title = "My Account"
  end

  # say something nice, you goof!  something sweet.
  def index
    @page_title = "Accounts"
    redirect_to(:action => 'new') unless logged_in? || User.count > 0
  end

  # GET /dt/accounts/1
  def show
    @user = User.find(params[:id], :include => [:user_transactions, :projects])
    @transactions = @user.user_transactions.find(:all, , :order => 'created_at DESC').paginate(:page => params[:tx_page], :per_page => 10)
  end

  # GET /dt/accounts/new
  def new
    @page_title = "Create My Account"
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
        session[:tmp_user] = @user.id
        flash[:notice] = 'Thanks for signing up! An activation email has been sent to your email address.'
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
    
    # password changing - requires the old password to be entered and correct
    if params[:old_password] && !current_user.authenticated?(params[:old_password])
      params[:old_password] = nil
      @user.errors.add('old_password', "was incorrect")
    end
    params[:user][:password] = nil if !params[:old_password]
    #params[:user][:password_confirmation] = nil if !params[:old_password]
    @user.change_password = false
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
      #MP - Dec 14, 2007
      #Added to support the us tax receipt functionality
      #If the user has indicated that they want a US tax 
      #receipt, the session variable should be set to false,
      #and the user notified that they can now follow the link
      #**Thought about an automatic redirect here, but decided
      #against it as it might be kinda weird to be redirected
      #when activating the account**. Also, the message below may
      #never be seen if the session expires before the user 
      #activates the account.
      if requires_us_tax_receipt?
        requires_us_tax_receipt(false)
        flash[:notice] = "Your email address has been confirmed and your account is activated!<br />You indicated that you require a US tax receipt.\nIf that is still the case, please follow the link and you will be taken to the correct location."
      else
       flash[:notice] = "Your email address has been confirmed and your account is activated!"
      end
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
  
  def reset
    respond_to do |format|
      format.html
    end
  end

  def reset_password
    @user = User.find_by_login(params[:login]) if params[:login]
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
        redirect_to dt_login_path and return if @user && saved
        flash[:error] = "We could not find that login. Did you try your email address?"
        render :action => 'reset'
      }
    end
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
