class BusAdmin::CausesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  active_scaffold :cause do |config|
    config.columns =[ :name, :description, :sectors, :millennium_goals ]
    list.columns.exclude [:sectors, :millennium_goals]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
   
   config.columns[:millennium_goals].association.reverse = :cause 
   
   config.columns[ :millennium_goals ].form_ui = :select
   config.columns[ :sectors ].form_ui = :select
    #show.columns.exclude [ ]
   end
   
    

end
