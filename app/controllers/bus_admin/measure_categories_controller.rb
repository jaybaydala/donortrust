class BusAdmin::MeasureCategoriesController < ApplicationController

  active_scaffold :measure_categories do |config|
    config.columns =[ :category, :description, :measures ]
    config.columns[ :category ].label = "Category Name"
    list.columns.exclude [ :measures ]
    update.columns.exclude [ :measures ]
    create.columns.exclude [ :measures ]
    #show.columns.exclude [ ]
  end

end
