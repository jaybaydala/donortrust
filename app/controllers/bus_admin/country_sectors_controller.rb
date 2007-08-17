class BusAdmin::CountrySectorsController < ApplicationController
  before_filter :login_required

  active_scaffold :country_sectors do |config|
    config.columns =[ :sector, :country, :content ]#, :continent
#    config.columns[ :continent ].form_ui = :select
    config.columns[ :country ].form_ui = :select
    config.columns[ :sector ].form_ui = :select
    list.columns.exclude [ :content ]
#    update.columns.exclude [ :continent ]
#    create.columns.exclude [ :continent ]
    #show.columns.exclude [  ]
  end
end
