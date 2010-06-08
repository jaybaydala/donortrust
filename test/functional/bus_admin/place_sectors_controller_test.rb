require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/place_sectors_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PlaceSectorsController; def rescue_action(e) raise e end; end

class BusAdmin::PlaceSectorsControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_place_sectors

  def setup
    @controller = BusAdmin::PlaceSectorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_place_sectors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_place_sector
    old_count = place_sector.count
    post :create, :place_sector => { }
    assert_equal old_count+1, place_sector.count
    
    assert_redirected_to place_sector_path(assigns(:place_sector))
  end

  def test_should_show_place_sector
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_place_sector
    put :update, :id => 1, :place_sector => { }
    assert_redirected_to place_sector_path(assigns(:place_sector))
  end
  
  def test_should_destroy_place_sector
    old_count = place_sector.count
    delete :destroy, :id => 1
    assert_equal old_count-1, place_sector.count
    
    assert_redirected_to bus_admin_place_sectors_path
  end
end
