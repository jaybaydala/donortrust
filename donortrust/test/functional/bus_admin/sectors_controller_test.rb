require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/sectors_controller'

# Re-raise errors caught by the controller.
class BusAdmin::SectorsController; def rescue_action(e) raise e end; end

class BusAdmin::SectorsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_sectors

  def setup
    @controller = BusAdmin::SectorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_sectors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_sector
    old_count = BusAdmin::Sector.count
    post :create, :sector => { }
    assert_equal old_count+1, BusAdmin::Sector.count
    
    assert_redirected_to sector_path(assigns(:sector))
  end

  def test_should_show_sector
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_sector
    put :update, :id => 1, :sector => { }
    assert_redirected_to sector_path(assigns(:sector))
  end
  
  def test_should_destroy_sector
    old_count = BusAdmin::Sector.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::Sector.count
    
    assert_redirected_to bus_admin_sectors_path
  end
end
