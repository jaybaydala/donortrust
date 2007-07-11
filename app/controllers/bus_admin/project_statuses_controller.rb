class BusAdmin::ProjectStatusesController < ApplicationController
  before_filter :login_required
  
  include ApplicationHelper
  
  active_scaffold :project_statuses do |config|
    config.columns =[ :name, :description, :projects_count, :projects ]
    config.columns[ :name ].label = "Status"
    config.columns[ :projects_count ].label = "Projects"
#    config.columns[:projects].form_ui = :select
#    config.columns[:project_histories].form_ui = :select
    #config.columns[:partner_type].form_ui = :select
    list.columns.exclude [ :description, :projects ]
#    show.columns.exclude [ ]
    update.columns.exclude [ :projects_count, :projects ]
    create.columns.exclude [ :projects_count, :projects ]
  end
  
  def destroy
    begin
      super.destroy
    rescue
      @error = "You cannot delete this status; it is being used by a project."
      flash[:error] = @error #for some reason this won't display      
      show_message_and_reset(@error, "error")        
    end
  end
    
end
