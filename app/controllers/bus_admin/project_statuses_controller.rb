class BusAdmin::ProjectStatusesController < ApplicationController
  before_filter :login_required
  
  include ApplicationHelper
  
  active_scaffold :project_statuses do |config|
    config.columns =[ :name, :description, :projects_count, :projects ]
    config.columns[ :name ].label = "Status"
    list.columns.exclude [ :projects_count, :projects ]
    update.columns.exclude [ :projects_count, :projects ]
    create.columns.exclude [ :projects_count, :projects ]
    #show.columns.exclude [ ]
  end
end
