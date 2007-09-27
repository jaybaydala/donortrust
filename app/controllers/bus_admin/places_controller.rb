class BusAdmin::PlacesController < ApplicationController
  before_filter :login_required#, :check_authorization
  
  active_scaffold :places do |config|
    config.columns =[ :name, :description, :place_type ]
    config.columns[ :place_type ].form_ui = :select
    config.nested.add_link("Next", [:children]) 
    config.nested.add_link("Quick Fact", [:quick_fact_places]) 
  end
  
  def list
    @places= Place.find_all_by_parent_id(nil)
  end
  
end