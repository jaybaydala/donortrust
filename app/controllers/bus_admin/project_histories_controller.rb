class BusAdmin::ProjectHistoriesController < ApplicationController  
  active_scaffold do |config|
    
    config.actions = [:list, :show, :nested]
  
#    config.actions.exclude :create
#    config.actions.exclude :delete
#    config.actions.exclude :update
    config.actions.exclude :nested

    config.list.columns = [:description, :total_cost, :dollars_raised, :dollars_spent, :bus_user, :date] # reorder columns 
    
    config.show.columns.exclude :project
    config.list.columns.exclude :project
    config.columns[:bus_user].label = "Modified By"
    config.columns[:date].label = "Modificaion Date"
    
    config.list.label = 'Project history'
    #config.nested.label = 'Project history'
    
  end

end
