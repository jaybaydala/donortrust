class BusAdmin::MilestoneStatusesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  include ApplicationHelper
  active_scaffold :milestone_statuses do |config|
    config.columns =[ :name, :description, :milestones_count, :milestones ]
    config.columns[ :name ].label = "Status"
    list.columns.exclude [ :milestones_count, :milestones ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    update.columns.exclude [ :milestones_count, :milestones ]
    create.columns.exclude [ :milestones_count, :milestones ]
    #show.columns.exclude [ ]
  end

  def get_model
    return MilestoneStatus
  end

end
