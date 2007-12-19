class BusAdmin::BudgetItemsController < ApplicationController
  # before_filter :login_required, :check_authorization
   
#  active_scaffold :budget_items do |config|
#    config.columns =[ :project, :description, :cost ]
#    config.columns[ :project ].form_ui = :select
#  
#  end

  def list_for_project
    puts params[:id]
  end

end
