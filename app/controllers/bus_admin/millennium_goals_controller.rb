class BusAdmin::MillenniumGoalsController < ApplicationController

    active_scaffold :millennium_goal do |config|
  
    show.columns.exclude [ :targets ]
    update.columns.exclude [ :targets]
    create.columns.exclude [ :targets ]
    config.nested.add_link( "Targets", [:targets])
    end

end
