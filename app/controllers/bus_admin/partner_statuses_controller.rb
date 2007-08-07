class BusAdmin::PartnerStatusesController < ApplicationController
  before_filter :login_required, :check_authorization
  include ApplicationHelper

  active_scaffold :partner_statuses do |config|
    config.columns =[ :name, :description, :partners_count ]
    list.columns.exclude :description
    update.columns.exclude :partners_count
    create.columns.exclude :partners_count
    #show.columns.exclude
  end
end
