class BusAdmin::MilestoneCategoriesController < ApplicationController

  active_scaffold :milestone_categories do |config|
    config.columns =[ :category, :description, :milestones, :milestone_histories ]
    config.columns[ :category ].label = "Category Name"
    list.columns.exclude [ :milestones, :milestone_histories ]
    update.columns.exclude [ :milestones, :milestone_histories ]
    create.columns.exclude [ :milestones, :milestone_histories ]
    show.columns.exclude [ :milestone_histories ]
  end

end
