class BusAdmin::QuickFactsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
  
  active_scaffold :quick_facts do |config|
    config.columns = [:name, :description, :quick_fact_type ]
    config.columns[ :quick_fact_type ].form_ui = :select
  end
  
end