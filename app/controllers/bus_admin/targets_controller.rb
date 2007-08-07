class BusAdmin::TargetsController < ApplicationController
  before_filter :login_required, :check_authorization

   active_scaffold :targets do |config|
    create.columns.exclude [ :millennium_goal ]
    update.columns.exclude [ :millennium_goal ]
    show.columns.exclude [ :indicators ]
    update.columns.exclude [ :indicators]
    create.columns.exclude [ :indicators ]
    config.nested.add_link( "Indicators", [:indicators])
  end
end
