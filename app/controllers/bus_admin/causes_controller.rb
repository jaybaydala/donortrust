class BusAdmin::CausesController < ApplicationController
  #before_filter :login_required, :check_authorization

  active_scaffold :cause do |config|
    config.columns =[ :name, :description, :sectors, :millennium_goals ]
    list.columns.exclude [:sectors, :millennium_goals]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
   
   config.columns[ :millennium_goals ].form_ui = :select
   config.columns[ :sectors ].form_ui = :select
    #show.columns.exclude [ ]
   end
   
    def get_model
    return FrequencyType
  end

end
