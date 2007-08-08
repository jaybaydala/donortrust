class BusAdmin::TaskVersionsController < ApplicationController

  active_scaffold do |config|
    config.actions = [:list, :show, :nested]
    config.columns =[ :milestone, :name, :start_date, :end_date, :etc_date, :description, :updated_at ]
    config.columns[ :name ].label = "Task"
    config.columns[ :start_date ].label = "Start"
    config.columns[ :end_date ].label = "End"
    config.columns[ :etc_date ].label = "Est Completion"
    list.columns.exclude [ :description ]
    #update.columns.exclude [  ]
    #create.columns.exclude [  ]
    #show.columns.exclude [  ]

    #config.action_links.add 'list', :label => 'Back', :parameters => {:controller => 'tasks', }, :page => true
  end
end