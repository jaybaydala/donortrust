class BusAdmin::IndicatorsController < ApplicationController
 before_filter :login_required, :check_authorization

  active_scaffold :indicators do |config|
    config.columns = [:description, :target, :indicator_measurement_count ]
    config.columns[ :indicator_measurement_count ].label = "Reference Count"
    list.columns.exclude [ :target, :indicator_measurement_count ]
    update.columns.exclude [ :target, :indicator_measurement_count ]
    create.columns.exclude [ :target, :indicator_measurement_count ]
     config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    
    #show.columns.exclude [  ]
  end
  
   def get_model
    return Indicator
  end
end
