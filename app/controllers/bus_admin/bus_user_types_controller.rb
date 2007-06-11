class BusAdmin::BusUserTypesController < ApplicationController

  active_scaffold :bus_user_types do |config|
    #config.create.columns.exclude :bus_secure_actions
    config.columns[:bus_secure_levels].association.reverse = :bus_secure_actions
    
  end
end
