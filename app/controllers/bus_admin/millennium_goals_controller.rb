class BusAdmin::MillenniumGoalsController < ApplicationController
  layout 'admin'
  access_control :DEFAULT => 'cf_admin' 

  active_scaffold :millennium_goal do |config|
    config.columns =[:name,  :description]
 
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    
  end
  
   def get_model
    return MillenniumGoal
  end
end
