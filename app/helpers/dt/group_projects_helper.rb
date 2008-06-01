module Dt::GroupProjectsHelper
  def group_invested(project, group)
    Investment.sum('amount', :conditions => {:project_id => project, :group_id => group})
  end
end
