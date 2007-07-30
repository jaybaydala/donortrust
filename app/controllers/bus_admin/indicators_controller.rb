class BusAdmin::IndicatorsController < ApplicationController
  before_filter :login_required

  active_scaffold :indicators do |config|
    config.columns = [:description, :target]  
    update.columns.exclude [ :target ]
    create.columns.exclude [ :target ]  
  end

end
