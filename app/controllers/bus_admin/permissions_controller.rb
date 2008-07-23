class BusAdmin::PermissionsController < ApplicationController

layout 'admin'

before_filter :login_required, :check_authorization
active_scaffold :permission do |config|
   config.columns = [:role, :authorized_action]
   config.columns[:role].form_ui = :select
   config.columns[:authorized_action].form_ui = :select
end


end
