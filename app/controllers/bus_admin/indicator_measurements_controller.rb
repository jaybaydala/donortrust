class BusAdmin::IndicatorMeasurementsController < ApplicationController
before_filter :login_required  

  active_scaffold :indicator_measurements do |config|
    create.columns.exclude [ :project ]
    update.columns.exclude [ :project ]
    config.columns[:indicator].form_ui = :select
    config.columns[:frequency_type].form_ui = :select
  end
  

end
