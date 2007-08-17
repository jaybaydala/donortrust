class BusAdmin::SectorsController < ApplicationController
  before_filter :login_required

  active_scaffold :sectors do |config|
    config.columns =[ :name, :description, :project_count, :country_count, :country_sectors ]
    config.columns[ :name ].label = "Sector"
    config.nested.add_link("Countries", [:country_sectors])
    list.columns.exclude [ :project_count, :country_count, :country_sectors ]
    update.columns.exclude [ :project_count, :country_count, :country_sectors ]
    create.columns.exclude [ :project_count, :country_count, :country_sectors ]
    show.columns.exclude [ :country_sectors ]
  end
end
