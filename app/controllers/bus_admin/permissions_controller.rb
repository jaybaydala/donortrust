class BusAdmin::PermissionsController < ApplicationController

layout 'admin'

before_filter :login_required, :check_authorization
active_scaffold :permission do |config|
  config.columns.exclude :id
end


end
