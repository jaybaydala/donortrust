module Dt::GroupProjectsHelper
  def current_member(group, user = current_user)
    @current_member ||= group.memberships.find_by_user_id(user) if user
  end

  def dt_get_involved_nav
    render 'dt/groups/get_involved_nav'
  end

  def dt_group_nav
    render 'dt/groups/group_nav'
  end
end
