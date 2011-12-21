class Dt::Groups::MembershipsController < DtApplicationController
  include GroupPermissions
  helper 'dt/get_involved'
  helper 'dt/groups'
  before_filter :admin_required, :only => [:promote, :demote]
  before_filter :login_required, :only => :create

  def initialize
    @topnav = 'get_involved'
  end

  def index
    @group = Group.find(params[:group_id])
    if @group.private? && !logged_in?
      login_required
      return
    end
    @page_title = "Members | #{@group.name}"
    @memberships = @group.memberships.paginate({:page => params[:page], :per_page => 10})
    @membership = Membership.find(:first, :conditions => {:user_id => current_user, :group_id => params[:group_id]}) if logged_in?
    @invitation = Invitation.new(:group => @group, :user => current_user) if @membership && (!@group.private? || (@group.private? && @membership.admin?))
    respond_to do |format|
      format.html # index.rhtml
    end
  end
    
  def create
    @group = Group.find(params[:group_id])
    @member = @group.memberships.build(:user => current_user, :membership_type => Membership.member)
    membership_saved = @group.private? ? false : @member.save
    respond_to do |format|
      if membership_saved
        flash[:notice] = "You successfully joined #{@group.name}."
      else
        flash[:notice] = 'You are not able to join that group directly.'
      end
      if @group.private?
        format.html { redirect_to dt_groups_path }
      else
        format.html { redirect_to dt_group_path(@group.id) }
      end
    end
  end
  
  def destroy
    @group = Group.find(params[:group_id])
    @membership = @group.memberships.find(params[:id])
    if current_user.id == @membership.user.id
      destroy_allowed = true
    else
      current_member = @group.memberships.find_by_user_id(current_user.id)
      destroy_allowed = current_member.admin? ? true : false
      destroy_allowed = false if @membership.founder?
    end
    @destroyed = @membership.destroy if destroy_allowed
    respond_to do |format|
      if @destroyed
        flash[:notice] = 'You have left the group' if current_user.id == @membership.user.id
        flash[:notice] = "You have removed #{@membership.user.full_name} from the group" if @destroyed && current_user.id != @membership.user.id
      end
      format.html { redirect_to dt_group_memberships_path(@group) }
    end
  end
  
  def promote
    @group = Group.find(params[:group_id])
    @membership = @group.memberships.find(params[:id])
    @promoted = @membership.update_attributes(:membership_type => Membership.admin) unless @membership.founder?
    respond_to do |format|
      if @promoted
        flash[:notice] = "#{@membership.user.full_name} was successfully promoted to Admin."
      else
        flash[:notice] = "#{@membership.user.full_name} could not be promoted to Admin."
      end
      format.html { redirect_to dt_memberships_path(@group) }
    end    
  end
  
  def demote
    @group = Group.find(params[:group_id])
    @membership = @group.memberships.find(params[:id])
    @demoted = @membership.update_attributes(:membership_type => Membership.member) unless @membership.founder?
    respond_to do |format|
      if @demoted
        format.html {
          flash[:notice] = "#{@membership.user.full_name} was successfully demoted to regular membership."
          redirect_to dt_memberships_path(@group) 
        }
      else
        format.html {
          flash[:notice] = "#{@membership.user.full_name} could not be demoted to regular membership."
          redirect_to dt_memberships_path(@group) 
        }
      end
    end    
  end

  protected
  def current_member
    @current_member ||= Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => params[:group_id]} if logged_in?
  end

  def access_denied
    respond_to do |format|
      format.html do
        if logged_in?
          flash[:notice] = "You do not have permissions to access that page"
          redirect_to dt_memberships_path(@group)
        else
          redirect_to login_path
        end
      end
    end
    false
  end
end
