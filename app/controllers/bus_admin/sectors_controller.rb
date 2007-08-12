class BusAdmin::SectorsController < ApplicationController
  before_filter :login_required

  active_scaffold :sectors do |config|
    config.columns =[ :name, :description, :project_count, :country_count ]
    config.columns[ :name ].label = "Sector"
    list.columns.exclude [ :project_count, :country_count ]
    update.columns.exclude [ :project_count, :country_count ]
    create.columns.exclude [ :project_count, :country_count ]
    #show.columns.exclude
  end
end
