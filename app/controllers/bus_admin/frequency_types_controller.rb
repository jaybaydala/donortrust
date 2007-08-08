class BusAdmin::FrequencyTypesController < ApplicationController
  before_filter :login_required

  active_scaffold :frequency_type do |config|
    config.columns =[ :name, :active, :indicator_measurement_count ]
    config.columns[ :indicator_measurement_count ].label = "Count"
    config.actions.exclude :delete
    #list.columns.exclude [  ]
    update.columns.exclude [ :indicator_measurement_count ]
    create.columns.exclude [ :indicator_measurement_count ]
    #show.columns.exclude [ ]
   end
end
