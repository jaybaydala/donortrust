require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/targets_controller'

# Re-raise errors caught by the controller.
class BusAdmin::TargetsController; def rescue_action(e) raise e end; end

class BusAdmin::TargetsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_targets

  def setup
    @controller = BusAdmin::TargetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_targets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_target
    old_count = BusAdmin::Target.count
    post :create, :target => { }
    assert_equal old_count+1, BusAdmin::Target.count
    
    assert_redirected_to target_path(assigns(:target))
  end

  def test_should_show_target
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_target
    put :update, :id => 1, :target => { }
    assert_redirected_to target_path(assigns(:target))
  end
  
  def test_should_destroy_target
    old_count = BusAdmin::Target.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Target.count
    
    assert_redirected_to bus_admin_targets_path
  end
end
