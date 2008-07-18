class BusAdmin::BudgetItemsController < ApplicationController
   
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
   
  active_scaffold :budget_items do |config|
    config.columns =[ :project, :description, :cost ]
    config.columns[ :project ].form_ui = :select
  
  end

end
