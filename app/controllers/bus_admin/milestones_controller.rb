class BusAdmin::MilestonesController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :milestones do |config|
    config.columns =[ :project, :name, :target_start_date, :target_end_date,
                           :actual_start_date, :actual_end_date, :description, :milestone_status,
      :tasks_count, :tasks ]#:parent_program,
    list.columns.exclude [ :description, :tasks, :tasks_count, :version_count, :actual_start_date, :actual_end_date ]
    #show.columns.exclude [ ]
    update.columns.exclude [ :project, :tasks_count, :tasks, :version_count ]#:parent_program,
    create.columns.exclude [ :parent_program, :project, :tasks, :tasks_count, :version_count ]#:parent_program,
    config.columns[ :name ].label = "Milestone"
    config.columns[ :tasks_count ].label = "Tasks"
    config.columns[ :milestone_status ].form_ui = :select
    config.columns[ :milestone_status ].label = "Status"
#   config.columns[ :parent_program ].label = "Program"
    config.nested.add_link("Tasks", [:tasks])
    
  end

 

end