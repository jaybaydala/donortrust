class BusAdmin::KeyMeasuresController < ApplicationController
  before_filter :login_required, :check_authorization  

  active_scaffold :key_measures do |config|
    config.columns =[ :units,  :measure, :project, :measurement_count, :key_measure_datas]   
    config.columns[ :measure ].form_ui = :select
    config.nested.add_link("Measurements Data", [:key_measure_datas])
    list.columns.exclude [ :measurement_count, :key_measure_datas ]
    update.columns.exclude [ :measurement_count, :key_measure_datas ]
    create.columns.exclude [ :measurement_count, :key_measure_datas ]
    config.columns[ :project ].form_ui = :select
  end
end
