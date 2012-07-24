class Dt::TellFriendsController < DtApplicationController
  before_filter :login_required, :only => :show
  
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
          pdf = create_pdf_proxy(@share)
          send_data pdf.render, :filename => pdf.filename, :type => "application/pdf"
          pdf.post_render
        end
      }
    end
  end
  
  def new
    load_ecards
    @share = Share.new(:e_card => @ecards.first)
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
    load_ecards
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
    if params[:share] && params[:share][:to_emails]
      emails(params[:share][:to_emails]).each do |email|
        @s = Share.new(@share.attributes)
        @s.to_email = email
        @s.save
        @shares << @s
        @unsaved << @s.to_email if @s.new_record?
      end
    end
    @noemails = true if @shares.empty?

    respond_to do |format|
      if verify_recaptcha(:model => @share, :message => "There was a ReCaptcha error. Please retry entering the words below")
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
      else
        format.html { render :action => "new" }
      end
    end
  end

  def preview
    load_ecards
    @share = Share.new( params[:share] )
    
    # there are a couple of necessary field just for previewing
    valid = true
    
    %w( email to_email ).each do |field|
      @share.send("#{field}=", "#{field}@example.com") unless @share.send(field + '?')
    end
    @share_mail = DonortrustMailer.create_share_mail(@share)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  protected

    def emails(email_list)
      email_list.to_s.split(%r{,\s*}).collect{|email| email.strip}
    end

    def load_ecards 
      @ecards = ECard.find(:all, :order => :id)
      @ecards.unshift(@ecards.delete_at(2)) unless @ecards.empty? # changing the default image
    end

end
