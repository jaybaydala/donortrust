class BusAdmin::ProjectCategoriesController < ApplicationController  
  before_filter :login_required
  active_scaffold :project_categories do |config|  
    config.list.columns = :description, :projects
    config.show.columns = :description, :projects
    config.update.columns = :description
    config.create.columns = :description
    config.columns[:description].label = "Category"
    
  end
    
end
