class Dt::MembershipsController < DtApplicationController
  before_filter :login_required

  def index
    @memberships = current_user.memberships

    respond_to do |format|
      format.html # index.rhtml
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
      format.html { redirect_to :action => 'index' }    	
    end
  
  end
  
  def destroy
    @membership = Membership.find params[:id] #:first, :conditions => {:group_id => params[:group_id], :user_id => current_user.id } 
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'index' }    	
    end
  end

  def bestow
    @membership = Membership.find(params[:id])     
    
    bestower = current_user.memberships.find :first, :conditions => {:group_id => @membership.group_id}
    
    if bestower.membership_type > 1
      @membership.update_attributes(:membership_type => 2) 
      flash[:notice] = 'Membership was successfully upgraded to Admin status.'
    else
      flash[:notice] = 'Must be an admin to bestow admin status on another member.'
    end
    respond_to do |format|
      format.html { redirect_to :action => 'index' }    	
    end    
  end
    
end




