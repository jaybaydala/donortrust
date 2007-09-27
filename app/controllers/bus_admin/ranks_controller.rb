class BusAdmin::RanksController < ApplicationController
  before_filter :login_required#, :check_authorization
  
  active_scaffold :ranks do |config|
    config.columns = [:rank_type, :rank  ]
    config.columns[ :rank_type ].form_ui = :select
  
  end

end
