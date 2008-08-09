class BusAdmin::MeasuresController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin' 

  active_scaffold :measures do |config|
    config.columns = [:description, :key_measures, :key_measures_count ]
    config.columns[ :key_measures_count ].label = "Reference Count"
    list.columns.exclude [ :key_measures, :key_measures_count ]
    update.columns.exclude [ :key_measures, :key_measures_count ]
    create.columns.exclude [ :key_measures, :key_measures_count ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
  end
  
  def get_model
    return Indicator
  end
end
