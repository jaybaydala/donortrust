class BusAdmin::ContinentsController < ApplicationController
  before_filter :login_required, :check_authorization
  active_scaffold

end
