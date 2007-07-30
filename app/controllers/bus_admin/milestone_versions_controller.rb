class BusAdmin::MilestoneVersionsController < ApplicationController

  active_scaffold do |config|
    config.actions = [:list, :show, :nested]
    config.columns =[ :project, :name, :target_date, :description, :milestone_status, :updated_at ]
    config.columns[ :name ].label = "Milestone"
    config.columns[ :milestone_status ].form_ui = :select
    config.columns[ :milestone_status ].label = "Status"
    list.columns.exclude [ :description ]
    #update.columns.exclude [  ]
    #create.columns.exclude [  ]
    #show.columns.exclude [  ]

    #config.action_links.add 'list', :label => 'Back', :parameters => {:controller => 'milestones', }, :page => true
  end
end