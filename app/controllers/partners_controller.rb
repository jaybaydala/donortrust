class PartnersController < ApplicationController
  active_scaffold :partner do |config|
    config.columns[:partner_status].ui_type = :select
    config.columns[:partner_type].ui_type = :select

    config.create.columns.exclude :partner_histories
    config.list.columns.exclude :partner_histories
    config.update.columns.exclude :partner_histories
    #config.show.columns.exclude :partner_histories
    #config.show.columns.add_group
    
  end
end
