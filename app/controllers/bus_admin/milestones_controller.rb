class BusAdmin::MilestonesController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 

  active_scaffold :milestones do |config|
    config.actions = [ :create, :update, :delete, :list, :nested ]
    
    config.columns = [ :project, :name, :target_date, :actual_date, :description,
                       :milestone_status, :tasks_count, :tasks ]
    list.columns   = [ :name, :project, :milestone_status, :target_date, :tasks_count ]

    update.columns.exclude [ :project, :tasks_count, :tasks, :version_count ]
    create.columns.exclude [ :parent_program, :project, :tasks, :tasks_count, :version_count ]

    config.columns[ :name ].label = "Milestone"
    config.columns[ :description ].form_ui = :textarea
    config.columns[ :tasks_count ].label = "Tasks"
    config.columns[ :milestone_status ].form_ui = :select
    config.columns[ :milestone_status ].label = "Status"
#   config.columns[ :parent_program ].label = "Program"
    config.nested.add_link("Tasks", [:tasks])
    
  end

 

end