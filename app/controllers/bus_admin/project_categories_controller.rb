class BusAdmin::ProjectCategoriesController < ApplicationController  
  before_filter :login_required

  active_scaffold :project_categories do |config|  
    config.columns = [ :description, :projects_count, :projects ]
    config.columns[ :description ].label = "Category"
    config.columns[ :projects_count ].label = "Projects"
    list.columns.exclude [ :projects ]
#    show.columns.exclude []
    update.columns.exclude [ :projects_count, :projects ]
    create.columns.exclude [ :projects_count, :projects ]
  end
end
