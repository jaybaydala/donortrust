class BusAdmin::ProjectStatusesController < ApplicationController
  before_filter :login_required
  active_scaffold :project_statuses do |config|
    config.columns[:projects].ui_type = :select
    config.columns[:project_histories].ui_type = :select
    #config.columns[:partner_type].ui_type = :select
    config.list.columns = :status_type, :description, :projects
    config.show.columns = :status_type, :description
    config.update.columns = :status_type, :description
    config.create.columns = :status_type, :description
    
  end
 end
