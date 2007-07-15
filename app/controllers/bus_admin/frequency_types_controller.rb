class BusAdmin::FrequencyTypesController < ApplicationController

  active_scaffold :frequency_type do |config|
 
    config.actions.exclude :delete
 
   end

end
