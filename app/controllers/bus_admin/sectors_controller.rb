class BusAdmin::SectorsController < ApplicationController
  before_filter :login_required

  #hpd incomplete implementation: join tables / models do not exist yet
  active_scaffold :sectors do |config|
    config.columns =[ :name, :description ]#, :project_count, :country_count
    list.columns.exclude :description
#    update.columns.exclude :project_count, :country_count
#    create.columns.exclude :project_count, :country_count
    #show.columns.exclude
  end
end
