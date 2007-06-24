class BusAdmin::MilestoneStatusesController < ApplicationController

  active_scaffold :milestone_statuses do |config|
    config.columns =[ :name, :description, :milestones ]
    #config.columns[ :name ].label = "Title"
    list.columns.exclude [ :milestones ]
    update.columns.exclude [ :milestones ]
    create.columns.exclude [ :milestones ]
    #show.columns.exclude [ ]
  end

end
