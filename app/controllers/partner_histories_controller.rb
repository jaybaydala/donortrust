class PartnerHistoriesController < ApplicationController
  active_scaffold do |config|
    #config.ignore_columns.add :partner_id
    
    config.actions = [:list, :show, :nested]
  
#    config.actions.exclude :create
#    config.actions.exclude :delete
#    config.actions.exclude :update
#    config.actions.exclude :nested
    
    config.list.columns.exclude :partner
    config.show.columns.exclude :partner
    
    config.list.label = 'Partner history'
    config.nested.label = 'Partner history'
    
  end
end
