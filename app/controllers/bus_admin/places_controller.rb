class BusAdmin::PlacesController < ApplicationController

active_scaffold :places do |config|
   # config.label = "Geography"
    config.columns =[ :name, :description, :place_type ]
    config.columns[ :place_type ].form_ui = :select
    config.nested.add_link("Next", [:children]) 
    config.nested.add_link("Quick Fact", [:quick_fact_places]) 
  end
  
  def list
    @places= Place.find_all_by_parent_id(nil)
  end
  
end


#active_scaffold :geography do |config|
#    config.label = "Geography"
#    config.columns =[ :name, :content, :geography_type ]
#    config.columns[ :geography_type ].form_ui = :select
#    config.nested.add_link("Next", [:children]) 
#    config.nested.add_link("Quick Fact", [:geography_quick_fact_refs]) 
#  end
#  
#  def list
#    @geographies= Geography.find_all_by_parent_id(nil)
#  end
#  
#end
