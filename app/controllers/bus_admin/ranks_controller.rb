class BusAdmin::RanksController < ApplicationController
 # before_filter :login_required, :check_authorization
  
  active_scaffold :ranks do |config|
    config.label = "At A Glance "
    config.columns[ :rank_value_id ].label = "Value"
    config.columns[ :rank_value_id ].form_ui = :select
    config.columns = [:rank_type, :rank_value_id  ]
    config.columns[ :rank_type ].form_ui = :select
  
  end

end
