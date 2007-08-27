class BusAdmin::MillenniumGoalsController < ApplicationController
  before_filter :login_required, :check_authorization
  active_scaffold :millennium_goal do |config|
    config.columns =[ :description, :target_count, :targets ]
    config.nested.add_link( "Targets", [:targets])
    list.columns.exclude [ :target_count, :targets ]
    update.columns.exclude [ :target_count, :targets ]
    create.columns.exclude [ :target_count, :targets ]
    show.columns.exclude [ :targets ]
     config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    
  end
  
   def get_model
    return MillenniumGoal
  end
end
