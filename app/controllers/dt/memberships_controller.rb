class Dt::MembershipsController < DtApplicationController
  before_filter :login_required

  def index
    @groups = current_user.groups

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def list    
    g = Group.find params[:group_id]
    @membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => params[:group_id]}    
    @memberships = g.memberships
    respond_to do |format|
      format.html # list.rhtml
    end
  end
    
  def join
    group_id = params[:group_id]
    group = Group.find group_id
    @membership = Membership.new(:group_id => group_id, :user_id => current_user.id, :membership_type => 1)
    membership_saved = false
    membership_saved = @membership.save if !group.private?
    
    respond_to do |format|
      if membership_saved
        flash[:notice] = 'Membership was successfully created.'
      else
        flash[:notice] = 'Membership was not successfully created.'
      end
      format.html { redirect_to :action => 'list', :group_id => group_id }
    end
  
  end
  
  def destroy
    @membership = Membership.find params[:id]
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
    end
  end

  def bestow  
    @membership = Membership.find(params[:id])     
    bestowing_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
    if bestowing_membership.admin?
      @membership.update_attributes(:membership_type => 2) 
      flash[:notice] = 'Membership was successfully upgraded to Admin status.'
    else
      flash[:notice] = 'Must be an admin to bestow admin status on another member.'
    end
    respond_to do |format|
      format.html { redirect_to :action => 'list', :group_id => @membership.group_id }             
    end    
  end

  def revoke      
    @membership = Membership.find(params[:id])     
    revoking_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
    if revoking_membership.admin? or revoking_membership.owner?
      @membership.update_attributes(:membership_type => 1) 
      flash[:notice] = 'Membership was successfully downgraded to User status.'
    else
      flash[:notice] = 'Must be an admin to revoke admin status on another member.'
    end
    respond_to do |format|
      format.html { redirect_to :action => 'list', :group_id => @membership.group_id }             
    end        
  end
   
end




