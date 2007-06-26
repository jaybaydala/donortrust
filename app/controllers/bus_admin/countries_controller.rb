class BusAdmin::CountriesController < ApplicationController
  before_filter :login_required
  active_scaffold :countries do |config|
    config.columns[:continent].ui_type = :select
    config.columns = [:name, :continent_id, :html_data]
    config.list.columns.exclude :html_data
  end

end
