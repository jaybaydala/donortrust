require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/bus_users_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BusUsersController; def rescue_action(e) raise e end; end

class BusAdmin::BusUsersControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_bus_users

  def setup
    @controller = BusAdmin::BusUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_bus_users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_bus_user
    old_count = BusAdmin::BusUser.count
    post :create, :bus_user => { }
    assert_equal old_count+1, BusAdmin::BusUser.count
    
    assert_redirected_to bus_user_path(assigns(:bus_user))
  end

  def test_should_show_bus_user
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_bus_user
    put :update, :id => 1, :bus_user => { }
    assert_redirected_to bus_user_path(assigns(:bus_user))
  end
  
  def test_should_destroy_bus_user
    old_count = BusAdmin::BusUser.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::BusUser.count
    
    assert_redirected_to bus_admin_bus_users_path
  end
end
