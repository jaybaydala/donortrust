class BusAdmin::MillenniumGoalsController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :millennium_goal do |config|
    config.columns =[ :description, :target_count, :targets ]
    config.columns[ :target_count ].label = "Target Count"
    config.nested.add_link( "Targets", [:targets])
    list.columns.exclude [ :targets ]
    update.columns.exclude [ :target_count, :targets ]
    create.columns.exclude [ :target_count, :targets ]
    show.columns.exclude [ :targets ]
  end
end
