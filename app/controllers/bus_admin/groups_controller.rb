class BusAdmin::GroupsController < ApplicationController

  active_scaffold :groups do |config|
    config.columns = [:name, :description, :projects, :public ]
    config.actions.exclude :add_existing #this doesn't appear to work
  end

end
