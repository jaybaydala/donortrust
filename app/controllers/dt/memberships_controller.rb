class Dt::MembershipsController < DtApplicationController
  before_filter :login_required, :except => :index
  helper 'dt/get_involved'

  def initialize
    @topnav = 'get_involved'
  end

  def index
    @group = Group.find(params[:group_id])
    @memberships = @group.memberships
    @membership = Membership.find(:first, :conditions => {:user_id => current_user.id, :group_id => params[:group_id]}) if logged_in?
    @invitation = Invitation.new(:group_id => @group.id, :user_id => current_user.id) if @membership && (!@group.private? || (@group.private? && @membership.admin?))
    respond_to do |format|
      format.html # index.rhtml
    end
  end
    
  def create
    group_id = params[:group_id]
    group = Group.find(group_id)
    @membership = Membership.find(:first, :conditions => {:user_id => current_user.id, :group_id => params[:group_id]})
    @member = Membership.new(:group_id => group.id, :user_id => current_user.id, :membership_type => 1)
    membership_saved = false
    membership_saved = @member.save unless group.private?
    
    respond_to do |format|
      if membership_saved
        flash[:notice] = "You successfully joined #{group.name}."
      else
        flash[:notice] = 'You are not able to join that group directly.'
      end
      if group.private?
        format.html { redirect_to :controller => 'dt/groups', :action => 'index' }
      else
        format.html { redirect_to :controller => 'dt/groups', :action => 'show', :id => group.id }
      end
    end
  end
  
  def destroy
    @member = Membership.find params[:id]
    destroyed = @member.destroy
    respond_to do |format|
      flash[:notice] = 'You have left the group' if destroyed && current_user.id == @member.user_id
      flash[:notice] = "You have removed #{@membership.user.name} from the group" if destroyed && current_user.id != @member.user_id
      format.html { redirect_to :action => 'index', :group_id => params[:group_id]}
    end
  end

  #def typify
  # params[:membership].each do |membership_id, membership|
  #   if member = Membership.find(membership_id)
  #     member.membership_type = membership[:membership_type]
  #     member.save
  #   end
  # end
  # respond_to do |format|
  #   flash[:notice] = 'Your member changes have been saved'
  #   format.html { redirect_to :action => 'index', :group_id => params[:group_id] }
  # end    
  #end
  
  def promote
    @membership = Membership.find(params[:id])     
    bestowing_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
    if bestowing_membership.admin?
      @membership.update_attributes(:membership_type => Membership.admin) 
      flash[:notice] = "#{@membership.user.name} was successfully promoted to Admin."
    else
      flash[:error] = 'You must be an admin to promote a member.'
    end
    respond_to do |format|
      format.html { redirect_to :action => 'index', :group_id => @membership.group_id }
    end    
  end
  
  def demote
    @membership = Membership.find(params[:id])     
    revoking_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
    revokable = false
    revokable = true if revoking_membership.admin? 
    revokable = false if revoking_membership.membership_type < @membership.membership_type
    if revokable 
      @membership.update_attributes(:membership_type => 1) 
      flash[:notice] = "#{@membership.user.name}  was demoted to regular membership."
    else
      flash[:notice] = 'You must be an admin to demote a member.'
    end
    respond_to do |format|
      format.html { redirect_to :action => 'index', :group_id => @membership.group_id }
    end    
  end
  
  #def bestow  
  #  @membership = Membership.find(params[:id])     
  #  bestowing_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
  #  if bestowing_membership.admin?
  #    @membership.update_attributes(:membership_type => 2) 
  #    flash[:notice] = 'Membership was successfully upgraded to Admin status.'
  #  else
  #    flash[:notice] = 'Must be an admin to bestow admin status on another member.'
  #  end
  #  respond_to do |format|
  #    format.html { redirect_to :action => 'index', :group_id => @membership.group_id }
  #  end    
  #end
  #
  #def revoke      
  #  @membership = Membership.find(params[:id])     
  #  revoking_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
  #  revokable = false
  #  revokable = true if revoking_membership.admin? 
  #  revokable = false if revoking_membership.membership_type < @membership.membership_type
  #  if revokable 
  #    @membership.update_attributes(:membership_type => 1) 
  #    flash[:notice] = 'Membership was downgraded to User status.'
  #  else
  #    flash[:notice] = 'Must be an admin to revoke admin status on another member.'
  #  end
  #  respond_to do |format|
  #    format.html { redirect_to :action => 'index', :group_id => @membership.group_id }
  #  end        
  #end
  
  protected
  def current_member
    @current_member ||= Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => params[:group_id]} if logged_in?
  end
  
  def authorized?
    if ['create'].include?(action_name)
       return false unless logged_in?
    end
    if ['update', 'destroy'].include?(action_name)
      return false unless logged_in? && current_member && current_member.admin?
    end
    true
  end
  
  def access_denied
    respond_to do |format|
      format.html do
        if logged_in?
          redirect_to :action => 'index', :group_id => params[:group_id]
        else
          store_location
          redirect_to dt_login_path
        end
      end
    end   
  end
end
