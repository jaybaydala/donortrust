class BusAdmin::RegionsController < ApplicationController
  before_filter :login_required, :check_authorization
  active_scaffold

end
