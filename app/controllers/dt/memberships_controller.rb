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
    @membership = Membership.find params[:id] #:first, :conditions => {:group_id => params[:group_id], :user_id => current_user.id } 
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'index'}
    end
  end

  def bestow  
    @membership = Membership.find(params[:id])     
    bestowing_membership = Membership.find :first, :conditions => {:user_id => current_user.id, :group_id => @membership.group_id}
    if bestowing_membership.membership_type > 1 
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
    if revoking_membership.membership_type > 1 or revoking_membership.membership_type < @membership
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




