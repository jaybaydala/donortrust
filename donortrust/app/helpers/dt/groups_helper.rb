module Dt::GroupsHelper
  def dt_account_nav
    render 'dt/accounts/account_nav'
  end
  
  def group_types
    GroupType.find(:all)
  end
  
  def group_causes(group)
    render :partial => 'cause', :collection => group.causes
  end
  
  def dt_group_nav
    render 'dt/groups/group_nav'
  end

  def dt_get_involved_nav
    render 'dt/groups/get_involved_nav'
  end

  def group_admin_nav
    render 'dt/groups/group_admin_nav'
  end
end
