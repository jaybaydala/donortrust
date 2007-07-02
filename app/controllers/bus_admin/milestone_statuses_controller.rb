class BusAdmin::MilestoneStatusesController < ApplicationController
  before_filter :login_required

  active_scaffold :milestone_statuses do |config|
    config.columns =[ :name, :description, :milestones_count, :milestones ]
    #config.columns[ :name ].label = "Title"
    config.columns[ :milestones_count ].label = "Milestones"
    list.columns.exclude [ :milestones ]
    update.columns.exclude [ :milestones_count, :milestones ]
    create.columns.exclude [ :milestones_count, :milestones ]
    #show.columns.exclude [ ]
  end
end
