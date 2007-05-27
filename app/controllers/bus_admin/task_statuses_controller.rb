class BusAdmin::TaskStatusesController < ApplicationController

  active_scaffold :task_statuses do |config|
    config.columns =[ :status, :description, :tasks, :task_histories ]
    config.columns[ :status ].label = "Title"
    list.columns.exclude [ :tasks, :task_histories ]
    update.columns.exclude [ :tasks, :task_histories ]
    create.columns.exclude [ :tasks, :task_histories ]
    show.columns.exclude [ :task_histories ]
  end

end
