class BusAdmin::TargetsController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :targets do |config|
    config.columns =[ :description, :millennium_goal, :indicator_count, :indicators ]
    config.nested.add_link( "Indicators", [:indicators])
    list.columns.exclude [ :indicator_count, :indicators ]
    update.columns.exclude [ :millennium_goal, :indicator_count, :indicators ]
    create.columns.exclude [ :millennium_goal, :indicator_count, :indicators ]
    show.columns.exclude [ :indicators ]
  end
end
