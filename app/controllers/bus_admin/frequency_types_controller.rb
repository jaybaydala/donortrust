class BusAdmin::FrequencyTypesController < ApplicationController
  layout 'admin'
 before_filter :login_required, :check_authorization

  active_scaffold :frequency_type do |config|
    config.columns =[ :name, :indicator_measurement_count ]
    config.columns[ :indicator_measurement_count ].label = "Reference Count"
    list.columns.exclude [ :indicator_measurement_count ]
    update.columns.exclude [ :indicator_measurement_count ]
    create.columns.exclude [ :indicator_measurement_count ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
   
    #show.columns.exclude [ ]
   end
   
    def get_model
    return FrequencyType
  end
end
