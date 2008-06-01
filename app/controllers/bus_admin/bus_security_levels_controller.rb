class BusAdmin::BusSecurityLevelsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  active_scaffold


end
