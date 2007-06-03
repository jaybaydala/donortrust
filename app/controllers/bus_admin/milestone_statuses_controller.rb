class BusAdmin::MilestoneStatusesController < ApplicationController

  active_scaffold :milestone_statuses do |config|
    config.columns =[ :status, :description, :milestones, :milestone_histories ]
    config.columns[ :status ].label = "Title"
    list.columns.exclude [ :milestones, :milestone_histories ]
    update.columns.exclude [ :milestones, :milestone_histories ]
    create.columns.exclude [ :milestones, :milestone_histories ]
    show.columns.exclude [ :milestone_histories ]
  end

end
