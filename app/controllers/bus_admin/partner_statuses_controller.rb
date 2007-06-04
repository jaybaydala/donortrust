class BusAdmin::PartnerStatusesController < ApplicationController

  before_filter :login_required

  active_scaffold :partner_statuses do |config|
    config.columns =[ :statusType, :description, :partners, :partner_histories ]
    config.columns[ :statusType ].label = "Title"
    list.columns.exclude [ :partners, :partner_histories ]
    update.columns.exclude [ :partners, :partner_histories ]
    create.columns.exclude [ :partners, :partner_histories ]
    show.columns.exclude [ :partner_histories ]
  end

end
