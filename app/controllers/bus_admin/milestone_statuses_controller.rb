class BusAdmin::MilestoneStatusesController < ApplicationController
  before_filter :login_required

  include ApplicationHelper

  active_scaffold :milestone_statuses do |config|
    config.columns =[ :name, :description, :milestones_count, :milestones ]
    config.columns[ :name ].label = "Status"
    list.columns.exclude [ :milestones_count, :milestones ]
    update.columns.exclude [ :milestones_count, :milestones ]
    create.columns.exclude [ :milestones_count, :milestones ]
    #show.columns.exclude [ ]
  end
end
