class BusAdmin::KeyMeasureDatasController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :key_measure_datas do |config|
    config.label = "Key Measure Data"
    config.columns =[ :value, :key_measure, :date, :comment ]
    config.columns[ :date ].label = "Measured"
    config.columns[ :key_measure ].label = "Key Measure"
    list.columns.exclude [ :comment ]
    config.columns[ :key_measure ].form_ui = :select    
  end
end