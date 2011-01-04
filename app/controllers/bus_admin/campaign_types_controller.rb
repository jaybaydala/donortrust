class BusAdmin::CampaignTypesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  active_scaffold do |config|
    config.list.columns = [:name, :has_teams]
  end
end
