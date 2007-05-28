require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/nations_controller'

# Re-raise errors caught by the controller.
class BusAdmin::NationsController; def rescue_action(e) raise e end; end

class BusAdmin::NationsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_nations

  def setup
    @controller = BusAdmin::NationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_nations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_nation
    old_count = BusAdmin::Nation.count
    post :create, :nation => { }
    assert_equal old_count+1, BusAdmin::Nation.count
    
    assert_redirected_to nation_path(assigns(:nation))
  end

  def test_should_show_nation
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_nation
    put :update, :id => 1, :nation => { }
    assert_redirected_to nation_path(assigns(:nation))
  end
  
  def test_should_destroy_nation
    old_count = BusAdmin::Nation.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Nation.count
    
    assert_redirected_to bus_admin_nations_path
  end
end
