require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/bus_security_levels_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BusSecurityLevelsController; def rescue_action(e) raise e end; end

class BusAdmin::BusSecurityLevelsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_bus_security_levels

  def setup
    @controller = BusAdmin::BusSecurityLevelsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_bus_security_levels)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_bus_security_level
    old_count = BusAdmin::BusSecurityLevel.count
    post :create, :bus_security_level => { }
    assert_equal old_count+1, BusAdmin::BusSecurityLevel.count
    
    assert_redirected_to bus_security_level_path(assigns(:bus_security_level))
  end

  def test_should_show_bus_security_level
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_bus_security_level
    put :update, :id => 1, :bus_security_level => { }
    assert_redirected_to bus_security_level_path(assigns(:bus_security_level))
  end
  
  def test_should_destroy_bus_security_level
    old_count = BusAdmin::BusSecurityLevel.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::BusSecurityLevel.count
    
    assert_redirected_to bus_admin_bus_security_levels_path
  end
end
