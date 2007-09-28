class BusAdmin::PlaceSectorsController < ApplicationController
  before_filter :login_required#, :check_authorization
  
  active_scaffold :place_sectors do |config|
      config.columns =[ :sector, :place, :content ]#, :continent
      config.columns[ :place ].form_ui = :select
      config.columns[ :sector ].form_ui = :select
      list.columns.exclude [ :content ]
  end

end

