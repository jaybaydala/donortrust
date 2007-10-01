class BusAdmin::SectorsController < ApplicationController
  before_filter :login_required#, :check_authorization

  active_scaffold :sectors do |config|
    config.columns =[ :name, :description, :project_count, :country_count, :place_sectors ]
    config.columns[ :name ].label = "Sector"
    config.nested.add_link("Countries", [:place_sectors])
    list.columns.exclude [ :project_count, :country_count, :place_sectors ]
    update.columns.exclude [ :project_count, :country_count, :place_sectors ]
    create.columns.exclude [ :project_count, :country_count, :place_sectors ]
    show.columns.exclude [ :place_sectors ]
    config.action_links.add 'inactive_records', :label => 'Show Inactive', :parameters =>{:action => 'inactive_records'}
    config.nested.add_link("Next", [:children])
    config.nested.add_link("Quick Fact", [:quick_fact_sectors])
       
  end
  
   def get_model
      return Sector
    end
    
    def list
      @sectors= Sector.find_all_by_parent_id(nil)
    end
  
  end