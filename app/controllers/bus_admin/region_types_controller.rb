class BusAdmin::RegionTypesController < ApplicationController
 before_filter :login_required, :check_authorization

  active_scaffold :region_types do |config|
    config.columns =[ :name, :region_count ]
    #list.columns.exclude
    update.columns.exclude :region_count
    create.columns.exclude :region_count
    #show.columns.exclude
  end
end
