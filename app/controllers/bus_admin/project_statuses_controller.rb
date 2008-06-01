class BusAdmin::ProjectStatusesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  
  include ApplicationHelper
  
  active_scaffold :project_statuses do |config|
    config.columns =[ :name, :description, :projects_count, :projects ]
    config.columns[ :name ].label = "Status"
    list.columns.exclude [ :projects_count, :projects ]
    update.columns.exclude [ :projects_count, :projects ]
    create.columns.exclude [ :projects_count, :projects ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
#    show.columns.exclude [ ]

  end
 
  def get_model
    return ProjectStatus
  end

end
