class BusAdmin::RolesController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin'
  include BusAdmin::RolesHelper
   
  active_scaffold do |config|
    config.list.columns = [:title, :users]
    config.create.columns = [:title]
    config.update.columns = [:title, :administrations]
    config.columns[:administrations].label = "Users with this role"
  end

  def add_user
    config.actions << :nested
    config.nested.add_link("Manage User-Role Assignments", [:users])
  end
end
