class BusAdmin::TasksController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :tasks do |config|
    config.columns =[ :milestone, :name, :start_date, :end_date, :etc_date, :description ]
    list.columns.exclude [ :description ]
    #show.columns.exclude [ ]
    update.columns.exclude [ :milestone, :version_count ]
    create.columns.exclude [ :version_count ]
    config.columns[ :milestone ].form_ui = :select
    config.columns[ :name ].label = "Task"
    config.columns[ :start_date ].label = "Start"
    config.columns[ :end_date ].label = "End"
    config.columns[ :etc_date ].label = "Est Completion"
  end

end