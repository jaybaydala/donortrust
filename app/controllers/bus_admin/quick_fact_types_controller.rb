class BusAdmin::QuickFactTypesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin' 
  
  active_scaffold :quick_fact_types do |config|
    config.columns = [:name, :description ]
  end

end
