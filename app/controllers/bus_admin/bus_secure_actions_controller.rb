class BusAdmin::BusSecureActionsController < ApplicationController

  active_scaffold :bus_secure_action do |config|
    #config.list.columns.exclude :bus_security_level
   
  end

end
