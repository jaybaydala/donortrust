class BusAdmin::TasksController < ApplicationController
  before_filter :login_required

  active_scaffold :tasks do |config|
    config.columns =[ :milestone, :name, :start_date, :end_date, :etc_date, :description ]
    list.columns.exclude [ :description, :milestone ]
    update.columns.exclude [ :milestone ]
    create.columns.exclude [ :milestone ]
    #show.columns.exclude [  ]
  end

end