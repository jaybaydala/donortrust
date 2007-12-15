require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/bus_secure_actions_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BusSecureActionsController; def rescue_action(e) raise e end; end

class BusAdmin::BusSecureActionsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_bus_secure_actions

  def setup
    @controller = BusAdmin::BusSecureActionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_bus_secure_actions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_bus_secure_action
    old_count = BusAdmin::BusSecureAction.count
    post :create, :bus_secure_action => { }
    assert_equal old_count+1, BusAdmin::BusSecureAction.count
    
    assert_redirected_to bus_secure_action_path(assigns(:bus_secure_action))
  end

  def test_should_show_bus_secure_action
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_bus_secure_action
    put :update, :id => 1, :bus_secure_action => { }
    assert_redirected_to bus_secure_action_path(assigns(:bus_secure_action))
  end
  
  def test_should_destroy_bus_secure_action
    old_count = BusAdmin::BusSecureAction.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::BusSecureAction.count
    
    assert_redirected_to bus_admin_bus_secure_actions_path
  end
end
