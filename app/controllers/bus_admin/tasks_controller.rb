class BusAdmin::TasksController < ApplicationController
  before_filter :login_required #, :check_authorization

  active_scaffold :tasks do |config|
    config.columns =[ :milestone, :name, :start_date, :end_date, :etc_date, :description, :task_versions ]
    config.columns[ :name ].label = "Task"
    config.columns[ :start_date ].label = "Start"
    config.columns[ :end_date ].label = "End"
    config.columns[ :etc_date ].label = "Est Completion"
    list.columns.exclude [ :description, :task_versions ]
    update.columns.exclude [ :milestone, :version_count, :task_versions ]
    create.columns.exclude [ :milestone, :version_count, :task_versions ]
    show.columns.exclude [ :task_versions ]
  end

end