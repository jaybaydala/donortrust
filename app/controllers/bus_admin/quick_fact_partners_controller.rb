class BusAdmin::QuickFactPartnersController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :quick_fact_partners do |config|
    config.label = "Quick Facts"
    config.columns = [ :quick_fact, :partner, :description ]    
    config.columns[ :quick_fact ].form_ui = :select
    config.columns[ :partner ].form_ui = :select    
  end
end

