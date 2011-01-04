class BusAdmin::TeamsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  active_scaffold do |config|
    # config.list.columns = [:name, :event_date]
  end
end
