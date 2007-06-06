class BusAdmin::PartnerStatusesController < ApplicationController
  before_filter :login_required

  active_scaffold :partner_statuses do |config|
    config.columns[ :statusType ].label = "Title"
    config.list.columns = :statusType, :description
    config.show.columns = :statusType, :description
    list.columns.exclude  :partners, :partner_histories 
    update.columns.exclude :partners, :partner_histories 
    create.columns.exclude :partners, :partner_histories 
    show.columns.exclude :partner_histories
  end

end
