class BusAdmin::CitiesController < ApplicationController
  before_filter :login_required
  active_scaffold
end
