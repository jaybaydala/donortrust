require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/ranks_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RanksController; def rescue_action(e) raise e end; end

context "BusAdmin::Ranks #route_for" do
  use_controller BusAdmin::RanksController
  
   setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should recognize the routes" do
    
    @rs.generate(:controller => "bus_admin/ranks", :action => "index").should.equal "/bus_admin/ranks"
  end
  
 end

