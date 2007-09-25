class BusAdmin::PlaceTypesController < ApplicationController

  active_scaffold :place_types do |config|
    config.columns = [:name ]
  end

end
