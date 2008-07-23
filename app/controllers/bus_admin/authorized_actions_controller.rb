class BusAdmin::AuthorizedActionsController < ApplicationController

layout 'admin'

before_filter :login_required, :check_authorization
active_scaffold do |config|
  config.columns.exclude :roles
  config.list.columns.exclude :permissions
  config.columns[:permissions].label = "Permitted Roles"
end

end
