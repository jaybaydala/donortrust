class BusAdmin::PartnerTypesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
  
  include ApplicationHelper
  
  active_scaffold :partner_type do |config|   
    config.label = "Partner Categories"
    config.columns =[ :name, :description, :partners_count, :partners ]
    list.columns.exclude [ :partners_count, :partners ]
    update.columns.exclude [ :partners_count, :partners ]
    create.columns.exclude [ :partners_count, :partners ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
 
    config.label = "Partner Types"
  end
   def get_model
    return PartnerType
  end
end
