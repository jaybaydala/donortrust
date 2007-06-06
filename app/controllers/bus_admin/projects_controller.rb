class BusAdmin::ProjectsController < ApplicationController
  before_filter :login_required  
  active_scaffold :project do |config|
    config.list.columns = [:name, :description, :expected_completion_date, 
                          :start_date, :end_date, :dollars_spent, :total_cost]                          
    config.show.columns = [:name, :description, :expected_completion_date, 
                          :start_date, :end_date, :dollars_spent, :total_cost]
    config.update.columns = [:name, :description, :expected_completion_date, 
                          :start_date, :end_date, :dollars_spent, :total_cost]
    config.create.columns = [:name, :description, :expected_completion_date, 
                          :start_date, :end_date, :dollars_spent, :total_cost]
  end

end
