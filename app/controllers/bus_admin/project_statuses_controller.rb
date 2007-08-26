class BusAdmin::ProjectStatusesController < ApplicationController
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
   
#  def destroy
#    begin
#      super.destroy
#    rescue
#      @error = "You cannot delete this status; it is being used by a project."
#      flash[:error] = @error #for some reason this won't display      
#      show_message_and_reset(@error, "error")        
#    end
#  end

end
