class BusAdmin::RankValuesController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :rank_values do |config|
   # config.actions.exclude :create
    config.columns =[ :rank_value, :file ]
    config.columns[ :file ].label = "Image File"
   # config.columns[ :rank_value ].form_ui = :select
    config.update.columns.exclude :rank_value
    config.create.multipart = true
    config.update.multipart = true   
  end
end
