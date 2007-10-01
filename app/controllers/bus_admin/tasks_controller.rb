class BusAdmin::TasksController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :tasks do |config|
    config.columns =[ :milestone, :name, :start_date, :end_date, :etc_date, :description ]
    config.columns[ :name ].label = "Task"
    config.columns[ :start_date ].label = "Start"
    config.columns[ :end_date ].label = "End"
    config.columns[ :etc_date ].label = "Est Completion"
    list.columns.exclude [ :description ]
    update.columns.exclude [ :milestone, :version_count ]
    create.columns.exclude [ :milestone, :version_count ]
    #show.columns.exclude [ ]
  end

end