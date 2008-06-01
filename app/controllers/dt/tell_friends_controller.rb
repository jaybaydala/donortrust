class Dt::TellFriendsController < ApplicationController
  before_filter :login_required, :only => :show
  include EmailParser
  
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
    @shares = []
    @share = Share.new( params[:share] )
    @share.user_id = current_user if logged_in?
    @share.ip = request.remote_ip
    @unsaved = []
    if params[:share] && params[:share][:to_email]
      saved = @share.save
      @shares << @share
      @unsaved << @share.to_email unless saved
    end
    if params[:to_emails]
      emails(params[:to_emails]).each do |email|
        @s = Share.new(@share.attributes)
        @s.to_email = email
        saved = @s.save
        @shares << @s
        @unsaved << @s.to_email unless saved
      end
    end
    @noemails = true if @shares.empty?
    
    respond_to do |format|
      if @unsaved.empty? && !@noemails
        flash.now[:notice] = "Your invitations have been sent"
        format.html
      else
        @ecards = ECard.find(:all, :order => :id)
        @project = Project.find(@share.project_id) if @share.project_id? && @share.project_id != 0
        @action_js = "dt/ecards"
        flash.now[:error] = "Emails could not be created for the following email addresses: #{@unsaved.join(', ')}" unless @unsaved.empty?
        flash.now[:error] = "You need to include at least one email" if @noemails
        format.html { render :action => "new" }
      end
    end
  end

  def confirm
    @shares = []
    @share = Share.new( params[:share] )
    @ecards = ECard.find(:all, :order => :id)
    @project = Project.find(@share.project_id) if @share.project_id? && @share.project_id != 0
    @action_js = "dt/ecards"

    @invalid_emails = []
    if params[:share] && params[:share][:to_email]
      @shares << @share
      @invalid_emails << @share.to_email unless @share.valid?
    end
    if params[:to_emails]
      emails(params[:to_emails]).each do |email|
        @s = Share.new(@share.attributes)
        @s.to_email = email
        valid = @s.valid?
        @shares << @s
        @invalid_emails << @s.to_email unless @s.valid?
      end
    end
    if (!params[:share] || !params[:share][:to_email]) && params[:to_emails]
      @share = @shares.first if @shares.first
      valid = @share.valid?
    end
    @noemails = true if @shares.empty?

    respond_to do |format|
      if @invalid_emails.empty? && !@noemails
        format.html { render :action => "confirm" }
      else
        flash.now[:error] = "Emails could not be created for the following email addresses: #{@invalid_emails.join(', ')}" unless @invalid_emails.empty?
        flash.now[:error] = "You need to include at least one email" if @noemails
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
end
