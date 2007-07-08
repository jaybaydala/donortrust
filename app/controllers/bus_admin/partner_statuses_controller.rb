class BusAdmin::PartnerStatusesController < ApplicationController
  before_filter :login_required

  active_scaffold :partner_statuses do |config|
    config.columns =[ :name, :description, :partners_count, :partners ]
    list.columns.exclude [ :description, :partners ]
    update.columns.exclude :partners_count, :partners
    create.columns.exclude :partners_count, :partners
#    show.columns.exclude
  end

end
