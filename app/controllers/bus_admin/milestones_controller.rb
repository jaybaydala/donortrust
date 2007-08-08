class BusAdmin::MilestonesController < ApplicationController
  before_filter :login_required

  active_scaffold :milestones do |config|
    config.columns =[ :project, :name, :target_date, :description, :milestone_status,
      :tasks_count, :tasks, :version_count, :milestone_versions ]#:parent_program,
    config.columns[ :name ].label = "Milestone"
    config.columns[ :tasks_count ].label = "Tasks"
    config.columns[ :milestone_status ].form_ui = :select
    config.columns[ :milestone_status ].label = "Status"
#    config.columns[ :parent_program ].label = "Program"
    config.columns[ :version_count ].label = "Versions"
    config.nested.add_link("Tasks", [:tasks])
    config.nested.add_link("History", [:milestone_versions])
    list.columns.exclude [ :description, :tasks, :milestone_versions ]
    update.columns.exclude [ :project, :tasks_count, :tasks, :version_count, :milestone_versions ]#:parent_program,
    create.columns.exclude [ :parent_program, :project, :tasks_count, :version_count, :milestone_versions ]#:parent_program,
    show.columns.exclude [ :milestone_versions ]
  end

end