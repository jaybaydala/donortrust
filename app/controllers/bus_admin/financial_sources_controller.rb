class BusAdmin::FinancialSourcesController < ApplicationController
  layout 'admin'

  before_filter :login_required, :check_authorization
  
  active_scaffold :financial_sources do |config|
    config.columns =[ :source, :amount, :project ]
    config.columns[ :project ].form_ui = :select  
  end  
end

