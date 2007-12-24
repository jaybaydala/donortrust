require "test/unit"
require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/deposits_controller'

# Re-raise errors caught by the controller.
class BusAdmin::DepositsController; def rescue_action(e) raise e end; end
  
class DepositsControllerTest < Test::Unit::TestCase
  fixtures :bus_accounts
  
  include AuthenticatedTestHelper
  
  def setup
    @controller = BusAdmin::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
   def test_should_get_new
    login_as :quentin
    get :new
    assert_response :success
  end
  
end