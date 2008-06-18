class BusAdmin::PlaceTypesController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :place_types do |config|
    config.columns = [:name ]
  end

end
