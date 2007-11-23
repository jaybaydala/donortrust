class BusAdmin::BusSecureActionsController < ApplicationController
before_filter :login_required, :check_authorization
  active_scaffold :bus_secure_action do |config|
    config.create.columns.exclude :bus_user_types
    config.list.columns.exclude :bus_user_types
    config.update.columns.exclude :bus_user_types   
  end
end
