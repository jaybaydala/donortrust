require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/villages_controller'

# Re-raise errors caught by the controller.
class BusAdmin::VillagesController; def rescue_action(e) raise e end; end

class BusAdmin::VillagesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_villages

  def setup
    @controller = BusAdmin::VillagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_villages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_village
    old_count = BusAdmin::Village.count
    post :create, :village => { }
    assert_equal old_count+1, BusAdmin::Village.count
    
    assert_redirected_to village_path(assigns(:village))
  end

  def test_should_show_village
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_village
    put :update, :id => 1, :village => { }
    assert_redirected_to village_path(assigns(:village))
  end
  
  def test_should_destroy_village
    old_count = BusAdmin::Village.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Village.count
    
    assert_redirected_to bus_admin_villages_path
  end
end
