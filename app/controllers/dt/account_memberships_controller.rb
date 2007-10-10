class Dt::AccountMembershipsController < DtApplicationController
  before_filter :login_required
  
  def index
    @groups = current_user.groups
  end

  def destroy
    @membership = Membership.find(params[:id])
    @membership.destroy
    respond_to do |format|
      flash[:notice] = "You have left the &quot;#{@membership.group.name}&quot; group."
      format.html { redirect_to dt_account_memberships_path(params[:group_id]) }
    end
  end
end
