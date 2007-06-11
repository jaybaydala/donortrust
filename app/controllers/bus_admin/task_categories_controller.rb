class BusAdmin::TaskCategoriesController < ApplicationController
  before_filter :login_required

  active_scaffold :task_categories do |config|
    config.columns =[ :category, :description, :tasks, :task_histories ]
    config.columns[ :category ].label = "Category Name"
    list.columns.exclude [ :tasks, :task_histories ]
    update.columns.exclude [ :tasks, :task_histories ]
    create.columns.exclude [ :tasks, :task_histories ]
    show.columns.exclude [ :task_histories ]
  end

end
