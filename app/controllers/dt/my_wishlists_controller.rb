class Dt::MyWishlistsController < DtApplicationController
  before_filter :login_required
  
  def initialize
    @page_title = 'My Wishlist'
  end
  
  def index
    redirect_to dt_account_path(current_user.id)
  end
  
  def new
    @project = Project.find(params[:project_id]) if params[:project_id]
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @project = Project.find(params[:project_id]) if params[:project_id]
    saved = current_user.projects << @project if @project
    respond_to do |format|
      format.html do
        flash[:notice] = "The project has been saved to your wishlist" if saved
        redirect_to dt_project_path(@project) and return if saved
        render :action => "new"
      end
    end
  end
  
  def destroy
    @wishlist = MyWishlist.find(params[:id]) if params[:id]
    deleted = MyWishlist.destroy(params[:id]) if @wishlist
    flash[:notice] = "You have removed the project from your wishlist" if deleted
    redirect_to dt_account_my_wishlists_path(:account_id => @wishlist.user)
  end
  
  def new_message
    if params[:project_id] && Project.exists?(params[:project_id])
      @project = Project.find(params[:project_id])
      current_user.projects << @project unless current_user.projects.include?(@project)
    end
    @share = Share.new
    @ecards = ECard.find(:all, :order => :id)
    @action_js = 'dt/ecards'
  end
  
  def preview
    @share = Share.new( params[:share] )
    @projects = Project.find(params["project_ids"])
    
    # there are a couple of necessary field just for previewing
    valid = true
    %w( email to_email ).each do |field|
      valid = false if !@share.send(field + '?')
    end
    if valid
      @share_mail = DonortrustMailer.create_wishlist_mail(@share, @projects)
    end
    respond_to do |format|
      flash.now[:error] = 'To preview your ecard, please provide your email and the recipient\'s email' if !valid
      format.html { render :layout => false }
    end
  end

  def confirm
    @share = Share.new( params[:share] )
    @ecards = ECard.find(:all, :order => :id)
    @projects = Project.find(params[:project_ids]) if params[:project_ids]
    valid_share = @share.valid?
    unless @projects
      @share.errors.add_to_base("At least one project should be selected") 
      valid_share = false
    end
    @action_js = "dt/ecards"
    respond_to do |format|
      if valid_share && @projects
        format.html { render :action => "confirm" }
      else
        format.html { render :action => "new_message" }
      end
    end
  end

  def send_message
    @share = Share.new( params[:share] )
    @share.user_id = current_user if logged_in?
    @share.wishlist = true
    @share.ip = request.remote_ip
    @projects = Project.find(params[:project_ids]) if params[:project_ids]
    @saved = @share.save
    respond_to do |format|
      if @saved
        if @share.update_attributes(:sent_at => Time.now.utc)
          DonortrustMailer.deliver_wishlist_mail(@share, @projects)
        end
        format.html
      else
        format.html { render :action => "new" }
      end
    end
  end  

  protected
  def authorized?
    return false unless logged_in? && params[:account_id].to_i == current_user.id
    true
  end
  
  def access_denied
    respond_to do |accepts|
      accepts.html do
        redirect_to dt_login_path and return if !logged_in?
        redirect_to dt_project_path(params[:project_id]) and return if params[:project_id]
        redirect_to dt_projects_path and return
      end
    end
    false
  end
end
