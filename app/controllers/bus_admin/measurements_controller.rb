class BusAdmin::MeasurementsController < ApplicationController
  before_filter :login_required

  active_scaffold :measurements do |config|
    config.columns =[ :value, :indicator_measurement, :date, :comment ]
    config.columns[ :date ].label = "Measured"
    config.columns[ :indicator_measurement ].label = "Units"
    list.columns.exclude [ :comment ]
    update.columns.exclude [ :indicator_measurement ]
    create.columns.exclude [ :indicator_measurement ]
    #show.columns.exclude [  ]
  end
end
