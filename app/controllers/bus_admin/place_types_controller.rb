class BusAdmin::PlaceTypesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
  
  active_scaffold :place_types do |config|
    config.columns = [:name ]
  end

end
