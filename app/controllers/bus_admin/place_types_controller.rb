class BusAdmin::PlaceTypesController < ApplicationController
 # before_filter :login_required, :check_authorization
  
  active_scaffold :place_types do |config|
    config.columns = [:name ]
  end

end
