class BusAdmin::KeyMeasureDatasController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 

  active_scaffold :key_measure_datas do |config|
    config.label = "Data Captured for: "
    config.columns =[ :value, :key_measure, :date, :comment ]
    config.columns[ :date ].label = "Measured"
    config.columns[ :key_measure ].label = "Key Measure"
    list.columns.exclude [ :comment ]
    config.columns[ :key_measure ].form_ui = :select    
  end
end