module GroupPermissions
  protected
  def membership_required_if_private_group
    group = find_group
    redirect_to_group and return false unless group
    return true unless group.private?
    return login_required unless logged_in?
    member = group.memberships.find_by_user_id(current_user.id)
    redirect_to_group and return false unless member
  end
  
  def membership_required
    group = find_group
    redirect_to_group and return false unless group
    return login_required unless logged_in?
    member = group.memberships.find_by_user_id(current_user.id)
    redirect_to_group and return false unless member
  end
  
  def admin_required
    group = find_group
    redirect_to_group and return false unless group
    return login_required unless logged_in?
    member = group.memberships.find_by_user_id(current_user.id)
    redirect_to_group and return false unless member && member.admin?
  end
  
  def founder_required
    group = find_group
    redirect_to_group and return false unless group
    return login_required unless logged_in?
    member = group.memberships.find_by_user_id(current_user.id)
    redirect_to_group and return false unless member && member.founder?
  end
  
  def redirect_to_group
    flash[:notice] = "You do not have permissions to access that page"
    redirect_to dt_group_path(find_group) and return if find_group
    redirect_to dt_groups_path
  end
  
  private 
  def find_group
    @find_group ||= Group.find(params[:group_id]) if params[:group_id] && Group.exists?(params[:group_id])
  end
end