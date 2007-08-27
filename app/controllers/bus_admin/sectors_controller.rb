class BusAdmin::SectorsController < ApplicationController
  before_filter :login_required, :check_authorization

  active_scaffold :sectors do |config|
    config.columns =[ :name, :description, :project_count, :country_count, :country_sectors ]
    config.columns[ :name ].label = "Sector"
    config.nested.add_link("Countries", [:country_sectors])
    list.columns.exclude [ :project_count, :country_count, :country_sectors ]
    update.columns.exclude [ :project_count, :country_count, :country_sectors ]
    create.columns.exclude [ :project_count, :country_count, :country_sectors ]
    show.columns.exclude [ :country_sectors ]
     config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    
  end
  
   def get_model
    return Sector
  end
end
