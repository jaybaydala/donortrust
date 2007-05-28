require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/regions_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RegionsController; def rescue_action(e) raise e end; end

class BusAdmin::RegionsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_regions

  def setup
    @controller = BusAdmin::RegionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_regions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_region
    old_count = BusAdmin::Region.count
    post :create, :region => { }
    assert_equal old_count+1, BusAdmin::Region.count
    
    assert_redirected_to region_path(assigns(:region))
  end

  def test_should_show_region
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_region
    put :update, :id => 1, :region => { }
    assert_redirected_to region_path(assigns(:region))
  end
  
  def test_should_destroy_region
    old_count = BusAdmin::Region.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Region.count
    
    assert_redirected_to bus_admin_regions_path
  end
end
