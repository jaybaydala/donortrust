class BusAdmin::RssFeedElementsController < ApplicationController
before_filter :login_required, :check_authorization
  active_scaffold

end
