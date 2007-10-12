class BusAdmin::KeyMeasuresController < ApplicationController
  #before_filter :login_required, :check_authorization  

  active_scaffold :key_measures do |config|
    config.columns =[ :units,  :measure, :project, :measurements_count, :key_measures_data ]
    config.columns[ :measure ].form_ui = :select
    
    config.nested.add_link("Measurements Data", [:key_measures_data])
    list.columns.exclude [ :measurements_count, :key_measures_data ]
    update.columns.exclude [ :project, :measurements_count, :key_measures_data ]
    create.columns.exclude [ :project, :measurements_count, :key_measures_data ]
    #show.columns.exclude [ ]
  end
end
