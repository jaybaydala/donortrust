class BusAdmin::CausesController < ApplicationController
 before_filter :login_required#, :check_authorization
  
  active_scaffold :causes do |config|
    config.columns = [:name, :description, :sector  ]
    config.columns[ :sector ].form_ui = :select
  end
end
