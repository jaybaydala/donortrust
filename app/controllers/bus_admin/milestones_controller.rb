class BusAdmin::MilestonesController < ApplicationController
  before_filter :login_required

  active_scaffold :milestones do |config|
    config.columns =[ :project, :name, :target_date, :description, :milestone_status, :tasks_count, :tasks ] 
    config.columns[ :name ].label = "Milestone"
    config.columns[ :tasks_count ].label = "Tasks"
    config.columns[ :project ].form_ui = :select
    config.columns[ :milestone_status ].form_ui = :select
    config.columns[ :milestone_status ].label = "Status"
    update.columns.exclude [ :project, :tasks_count, :tasks ]
    list.columns.exclude [ :description, :tasks ]
    create.columns.exclude [ :tasks_count ]
    #show.columns.exclude [ ]
    config.nested.add_link("Tasks", [:tasks])  
  end

end