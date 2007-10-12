class BusAdmin::KeyMeasuresDataController < ApplicationController

 # before_filter :login_required, :check_authorization

  active_scaffold :key_measures_data do |config|
    config.columns =[ :value, :key_measure, :date, :comment ]
    config.columns[ :date ].label = "Measured"
    config.columns[ :key_measure ].label = "Key Measure"
    list.columns.exclude [ :comment ]
    update.columns.exclude [ :indicator_measurement ]
    create.columns.exclude [ :indicator_measurement ]
    #show.columns.exclude [  ]
  end
end
