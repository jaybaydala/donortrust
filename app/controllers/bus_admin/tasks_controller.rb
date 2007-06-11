class BusAdmin::TasksController < ApplicationController
  before_filter :login_required

  active_scaffold :tasks do |config|
    config.columns =[ :milestone, :title, :start_date, :end_date, :etc_date, :task_category, :task_status, :description, :task_histories ]
    config.columns[ :task_status ].label = "Status"
    config.columns[ :task_status ].ui_type = :select 
    config.columns[ :task_category ].label = "Category"
    config.columns[ :task_category ].ui_type = :select
    config.columns[ :task_histories ].label = "History"
    list.columns.exclude [ :description, :milestone, :task_histories ]
    update.columns.exclude [ :milestone, :task_histories ]
    create.columns.exclude [ :milestone, :task_histories ]
    #show.columns.exclude [ :task_histories ]
  end

end
