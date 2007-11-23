module Dt::AccountMembershipsHelper
  def group_causes(group)
    render :partial => 'dt/groups/cause', :collection => group.causes
  end
  
  def current_member(group, user = current_user)
    @current_member ||= group.memberships.find_by_user_id(user) if user
  end
end
