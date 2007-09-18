class Dt::MembershipsController < DtApplicationController
  before_filter :login_required

  def index
    @memberships = current_user.memberships

    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  def join
    @membership = Membership.new(:group_id => params[:group_id], :user_id => current_user.id, :membership_type => 1)
    respond_to do |format|
      if @membership.save
    	flash[:notice] = 'Membership was successfully created.'
        format.html { redirect_to dt_membership_url(@membership) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
end
