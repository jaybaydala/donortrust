class Dt::TellFriendsController < DtApplicationController
  before_filter :login_required, :only => :show
  before_filter :trim_emails, :only => [:confirm, :create]
  
  def initialize
    @page_title = "Tell a Friend"
  end

  def index
    redirect_to :action => "new"
  end
  
  def show
    @share = Share.find(params[:id])
    respond_to do |format|
      format.pdf {
        if not @share[:pickup_code]
          flash[:notice] = "The gift has already been picked up so the printable card is no longer available."
          redirect_to :action => 'new'
        else
          proxy = create_pdf_proxy(@share)
          send_data proxy.render, :filename => proxy.filename, :type => "application/pdf"
        end
      }
    end
  end
  
  def new
    store_location
    @share = Share.new
    @ecards = ECard.find(:all, :order => :id)
    @action_js = "dt/ecards"
    if params[:project_id]
      @project = Project.find(params[:project_id]) 
      @share.project_id = @project.id if @project
    end
    if logged_in?
      user = User.find(current_user.id)
      %w( email first_name last_name address city province postal_code country ).each {|f| @share[f.to_sym] = current_user[f.to_sym] }
      @share[:name] = current_user.full_name if logged_in?
      @share[:email] = current_user.email
    end
  end

  def create
    @share = Share.new( params[:share] )
    @share.user_id = current_user if logged_in?
    @share.ip = request.remote_ip
    @saved = @share.save
    respond_to do |format|
      if @saved
        # send the email if it's not scheduled for later.
        @share.send_share_mail
        format.html
      else
        format.html { render :action => "new" }
      end
    end
  end

  def confirm
    @share = Share.new( params[:share] )
    @ecards = ECard.find(:all, :order => :id)
    @project = Project.find(@share.project_id) if @share.project_id? && @share.project_id != 0
    @action_js = "dt/ecards"
    respond_to do |format|
      if @share.valid?
        format.html { render :action => "confirm" }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def preview
    @share = Share.new( params[:share] )
    
    # there are a couple of necessary field just for previewing
    valid = true
    %w( email to_email ).each do |field|
      valid = false if !@share.send(field + '?')
    end
    if valid
      @share_mail = DonortrustMailer.create_share_mail(@share)
    end
    respond_to do |format|
      flash.now[:error] = 'To preview your ecard, please provide your email and the recipient\'s email' if !valid
      format.html { render :layout => false }
    end
  end

  protected
  def trim_emails
    params[:share][:to_email].sub!(/^ *mailto: */, '') if params[:share][:to_email]
    params[:share][:email].sub!(/^ *mailto: */, '') if params[:share][:email]
  end
end
