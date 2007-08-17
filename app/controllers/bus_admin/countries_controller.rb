class BusAdmin::CountriesController < ApplicationController
  before_filter :login_required

  active_scaffold :countries do |config|
    config.columns = [:name, :continent, :html_data, :country_sectors]
    config.columns[:continent].ui_type = :select
    config.nested.add_link("Sectors", [:country_sectors])
    list.columns.exclude [ :html_data, :country_sectors ]
    update.columns.exclude [ :country_sectors ]
    create.columns.exclude [ :country_sectors ]
    #show.columns.exclude [  ]
  end
end
