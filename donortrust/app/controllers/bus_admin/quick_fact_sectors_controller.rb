class BusAdmin::QuickFactSectorsController < ApplicationController
  before_filter :login_required, :check_authorization
  
  active_scaffold :quick_fact_sectors do |config|
    config.label = "Quick Facts"
    config.columns = [ :quick_fact,:sector, :description ]    
    config.columns[ :quick_fact ].form_ui = :select
    config.columns[ :sector ].form_ui = :select        
  end
  
end
