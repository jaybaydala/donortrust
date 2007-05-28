class BusAdmin::ContinentsController < ApplicationController
  before_filter :login_required
  active_scaffold

end
