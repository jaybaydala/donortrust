class BusAdmin::TasksController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :tasks do |config|
    config.columns =[ :milestone, :name, :target_start_date, :target_end_date,
                           :actual_start_date, :actual_end_date, :description, :percent_complete ]
    list.columns.exclude [ :description, :actual_start_date, :actual_end_date, :percent_complete ]
    #show.columns.exclude [ ]
    update.columns.exclude [ :milestone, :version_count ]
    create.columns.exclude [ :version_count ]
    config.columns[ :milestone ].form_ui = :select
    config.columns[ :name ].label = "Task"
    config.columns[ :target_start_date ].label = "Target Start"
    config.columns[ :target_end_date ].label = "Target End"
    config.columns[ :actual_start_date ].label = "Actual Start"
    config.columns[ :actual_end_date ].label = "Actual End"
  end

end