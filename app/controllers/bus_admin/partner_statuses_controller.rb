class BusAdmin::PartnerStatusesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  include ApplicationHelper

  active_scaffold :partner_statuses do |config|
    config.columns =[ :name, :description, :partners_count, :partners ]
    list.columns.exclude [ :partners_count, :partners ]
    update.columns.exclude [ :partners_count, :partners ]
    create.columns.exclude [ :partners_count, :partners ]
     config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    
    #show.columns.exclude
  end
  
  def get_model
    return PartnerStatus
  end
end
