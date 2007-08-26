class BusAdmin::IndicatorMeasurementsController < ApplicationController
  before_filter :login_required, :check_authorization  

  active_scaffold :indicator_measurements do |config|
    config.columns =[ :units, :frequency_type, :indicator, :project, :measurements_count, :measurements ]
    config.columns[ :indicator ].form_ui = :select
    config.columns[ :frequency_type ].form_ui = :select
    config.columns[ :frequency_type ].label = "Frequency"
    config.nested.add_link("Measurements", [:measurements])
    list.columns.exclude [ :measurements_count, :measurements ]
    update.columns.exclude [ :project, :measurements_count, :measurements ]
    create.columns.exclude [ :project, :measurements_count, :measurements ]
    #show.columns.exclude [ ]
  end
end
