class BusAdmin::RanksController < ApplicationController
  before_filter :login_required, :check_authorization
  
  active_scaffold :ranks do |config|
    config.label = "At A Glance "
    config.columns[ :rank ].label = "Value from (0-4)"
    config.columns = [:rank_type, :rank  ]
    config.columns[ :rank_type ].form_ui = :select
  
  end

end
