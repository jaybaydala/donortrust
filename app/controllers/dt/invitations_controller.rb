class Dt::InvitationsController < DtApplicationController
  before_filter :login_required

  def new
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.ip = request.remote_ip
    if @invitation.group && @invitation.group.private?
      unless @invitation.user && @invitation.group.member(@invitation.user) && @invitation.group.member(@invitation.user).admin?
        flash[:error] = "Access denied"
        redirect_to dt_group_path(params[:group_id]) and return 
      end
    end
    @unsaved = []
    @invitations = []
    if params[:invitation] && params[:invitation][:to_email]
      saved = @invitation.save
      @invitations << @invitation
      @unsaved << @invitation.to_email unless saved
    end
    if (params[:to_emails]) 
      emails(params[:to_emails]).each do |email|
        @i = Invitation.new(@invitation.attributes)
        @i.to_email = email
        saved = @i.save
        @invitations << @i
        @unsaved << @i.to_email unless saved
      end
    end
    @noemails = true if (params[:invitation][:to_email].nil? || params[:invitation][:to_email].empty?) && (params[:to_emails].nil? || params[:to_emails].empty?)
    respond_to do |format|
      format.html do
        flash[:error] = "Invitations could not be created for the following emails: #{@unsaved.join(', ')}" unless @unsaved.empty?
        flash[:notice] = "Your invitations have been sent" if @unsaved.empty? && !@noemails
        flash[:error] = "You need to include at least one email" if @noemails
        redirect_to dt_group_memberships_path(:group_id => params[:group_id])
      end
    end
  end
  
  def update
    @invitation = Invitation.find(params[:id])
    if current_user.email == @invitation.to_email
      @invitation.accepted = params[:accepted]
      @saved = @invitation.save
      if @invitation.accepted?
        if @saved && Membership.create(:group_id => @invitation.group_id, :user_id => current_user.id)
          flash[:notice] = 'You have accepted the invitation and are now a member of the group'
        else
          flash[:error] = 'There was an error saving your membership'
        end
      else
        flash[:notice] = 'You have declined the invitation to join this group'
      end
    else
      flash[:error] = 'Access denied'
    end
    respond_to do |format|
      format.html { redirect_to dt_group_path(params[:group_id]) }
    end
  end
  
  protected
    def access_denied
      redirect_to dt_login_path and return unless logged_in?
    end

    def emails(email_list)
      emails = email_list.class == String ? email_list.split(%r{,\s*}) : email_list
      emails.collect! { |email| email.strip }
      emails
    end

end
