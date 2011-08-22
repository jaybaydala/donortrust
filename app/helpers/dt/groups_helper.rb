module Dt::GroupsHelper
  def current_member(group=nil, user = current_user)
    group = group.nil? && @group ? @group : group
    return if group.nil?
    group.memberships.find_by_user_id(user) if user
  end

  def iend_user_nav
    render :file => 'iend/shared/nav'
  end
  
  def group_types
    GroupType.find(:all)
  end
  
  def group_causes(group)
    render :partial => 'dt/groups/cause', :collection => group.causes
  end
  
  def dt_group_nav
    render :file => 'dt/groups/group_nav'
  end

  def dt_get_involved_nav
    render :file => 'dt/groups/get_involved_nav'
  end

  def group_admin_nav
    render :file => 'dt/groups/group_admin_nav'
  end
end
