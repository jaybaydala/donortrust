class BusAdmin::MilestoneStatusesController < ApplicationController
  before_filter :login_required

  include ApplicationHelper

  active_scaffold :milestone_statuses do |config|
    config.columns =[ :name, :description ]
    #list.columns.exclude [  ]
    #update.columns.exclude [  ]
    #create.columns.exclude [  ]
    #show.columns.exclude [  ]
  end
end
