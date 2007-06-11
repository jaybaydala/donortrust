class BusAdmin::UrbanCentresController < ApplicationController
  before_filter :login_required
  active_scaffold :urban_centres do |config|
    config.columns = [:urban_centre_name, :blog_name, :rss_url, :population, :village_plan, :region, :facebook_group_id]
    config.columns[ :urban_centre_name ].label = "Name"
  end

  
end
