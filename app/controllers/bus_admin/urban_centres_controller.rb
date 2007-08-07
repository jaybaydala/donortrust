class BusAdmin::UrbanCentresController < ApplicationController
  before_filter :login_required, :check_authorization
  active_scaffold :urban_centres do |config|
    config.columns = [:name, :blog_name, :blog_url, :rss_url, :population, :village_plan, :region, :facebook_group_id]
    config.list.columns = [:name,  :region, :blog_name, :population,:facebook_group_id]
    config.columns[ :name ].label = "Name"
  end

  
end
