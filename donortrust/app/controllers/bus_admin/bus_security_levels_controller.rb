class BusAdmin::BusSecurityLevelsController < ApplicationController
  before_filter :login_required, :check_authorization
  active_scaffold


end
