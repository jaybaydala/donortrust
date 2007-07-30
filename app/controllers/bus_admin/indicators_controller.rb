class BusAdmin::IndicatorsController < ApplicationController
  before_filter :login_required

  active_scaffold :indicators do |config|
    config.columns = [:description, :target]    
  end

end
