require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/causes_controller'

# Re-raise errors caught by the controller.
class BusAdmin::CausesController; def rescue_action(e) raise e end; end

class BusAdmin::CausesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_causes

  def setup
    @controller = BusAdmin::CausesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_causes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_cause
    old_count = cause.count
    post :create, :cause => { }
    assert_equal old_count+1, cause.count
    
    assert_redirected_to cause_path(assigns(:cause))
  end

  def test_should_show_cause
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_cause
    put :update, :id => 1, :cause => { }
    assert_redirected_to cause_path(assigns(:cause))
  end
  
  def test_should_destroy_cause
    old_count = cause.count
    delete :destroy, :id => 1
    assert_equal old_count-1, cause.count
    
    assert_redirected_to bus_admin_causes_path
  end
end
