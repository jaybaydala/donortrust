class BusAdmin::PartnerHistoriesController < ApplicationController
  before_filter :login_required
  active_scaffold do |config|
    #config.ignore_columns.add :partner_id
    
    config.actions = [:list, :show, :nested]
    
    #    config.actions.exclude :create
    #    config.actions.exclude :delete
    #    config.actions.exclude :update
    #    config.actions.exclude :nested
    
    config.list.columns = [:name, :description, :partner_status, :partner_type, :bus_user, :created_on] # reorder columns 
    
    config.show.columns.exclude :partner
    config.columns[:bus_user].label = "Modified By"
    config.columns[:created_on].label = "Modificaion Date"
    #config.list.columns.add :bus_user_id#BusUser.find_by_id(:bus_user_id).login
    
    config.list.label = 'Partner history'
    config.nested.label = 'Partner history'
    
  end
end
