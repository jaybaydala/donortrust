class BusAdmin::GroupTypesController < ApplicationController
  before_filter :login_required

  active_scaffold :group_type do |config|
    config.columns =[ :name, :group_count ]
    list.columns.exclude [ :group_count ]
    update.columns.exclude [ :group_count ]
    create.columns.exclude [ :group_count ]
    #show.columns.exclude [ ]
   end
end
