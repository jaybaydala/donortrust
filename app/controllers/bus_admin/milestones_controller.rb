class BusAdmin::MilestonesController < ApplicationController
  before_filter :login_required

  active_scaffold :milestones do |config|
    config.columns =[ :project, :name, :target_date, :description, :milestone_status, :tasks ]
    config.columns[ :milesstone_status ].label = "Status"
    list.columns.exclude [ :description, :project, :tasks ]#add project back in? nested?
    #update.columns.exclude [ :tasks ]
    #create.columns.exclude [ :tasks ]
    #show.columns.exclude [ ]
  end

end