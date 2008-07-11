class BusAdmin::FinancialSourcesController < ApplicationController
  
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :financial_sources do |config|
    config.columns =[ :source, :amount, :project, :received_on ]
    config.columns[ :project ].form_ui = :select  
  end  
end

