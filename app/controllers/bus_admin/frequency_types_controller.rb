class BusAdmin::FrequencyTypesController < ApplicationController
 before_filter :login_required, :check_authorization

  active_scaffold :frequency_type do |config|
    config.columns =[ :name, :active, :indicator_measurement_count ]
    config.columns[ :indicator_measurement_count ].label = "Reference Count"
    config.actions.exclude :delete
    list.columns.exclude [ :indicator_measurement_count ]
    update.columns.exclude [ :indicator_measurement_count ]
    create.columns.exclude [ :indicator_measurement_count ]
    #show.columns.exclude [ ]
   end
end
