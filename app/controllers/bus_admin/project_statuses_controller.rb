class BusAdmin::ProjectStatusesController < ApplicationController
  before_filter :login_required

  active_scaffold :project_statuses do |config|
    config.columns =[ :name, :description, :projects_count, :projects ]
    config.columns[ :name ].label = "Status"
    config.columns[ :projects_count ].label = "Projects"
#    config.columns[:projects].ui_type = :select
#    config.columns[:project_histories].ui_type = :select
    #config.columns[:partner_type].ui_type = :select
    list.columns.exclude [ :description, :projects ]
#    show.columns.exclude [ ]
    update.columns.exclude [ :projects_count, :projects ]
    create.columns.exclude [ :projects_count, :projects ]
  end
 end
