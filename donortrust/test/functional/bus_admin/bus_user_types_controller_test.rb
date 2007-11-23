require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/bus_user_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BusUserTypesController; def rescue_action(e) raise e end; end

class BusAdmin::BusUserTypesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_bus_user_types

  def setup
    @controller = BusAdmin::BusUserTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_bus_user_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_bus_user_type
    old_count = BusAdmin::BusUserType.count
    post :create, :bus_user_type => { }
    assert_equal old_count+1, BusAdmin::BusUserType.count
    
    assert_redirected_to bus_user_type_path(assigns(:bus_user_type))
  end

  def test_should_show_bus_user_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_bus_user_type
    put :update, :id => 1, :bus_user_type => { }
    assert_redirected_to bus_user_type_path(assigns(:bus_user_type))
  end
  
  def test_should_destroy_bus_user_type
    old_count = BusAdmin::BusUserType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::BusUserType.count
    
    assert_redirected_to bus_admin_bus_user_types_path
  end
end
