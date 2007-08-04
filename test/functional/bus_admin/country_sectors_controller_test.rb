require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/country_sectors_controller'

# Re-raise errors caught by the controller.
class BusAdmin::CountrySectorsController; def rescue_action(e) raise e end; end

class BusAdmin::CountrySectorsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_country_sectors

  def setup
    @controller = BusAdmin::CountrySectorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_country_sectors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_country_sector
    old_count = country_sector.count
    post :create, :country_sector => { }
    assert_equal old_count+1, country_sector.count
    
    assert_redirected_to country_sector_path(assigns(:country_sector))
  end

  def test_should_show_country_sector
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_country_sector
    put :update, :id => 1, :country_sector => { }
    assert_redirected_to country_sector_path(assigns(:country_sector))
  end
  
  def test_should_destroy_country_sector
    old_count = country_sector.count
    delete :destroy, :id => 1
    assert_equal old_count-1, country_sector.count
    
    assert_redirected_to bus_admin_country_sectors_path
  end
end
