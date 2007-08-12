class BusAdmin::PartnerTypesController < ApplicationController
  before_filter :login_required
  
  include ApplicationHelper
  
  active_scaffold :partner_type do |config|   
    config.label = "Partner Categories"
    config.columns =[ :name, :description, :partners_count, :partners ]
    list.columns.exclude [ :partners_count, :partners ]
    update.columns.exclude [ :partners_count, :partners ]
    create.columns.exclude [ :partners_count, :partners ]
    #show.columns.exclude
  end
end
