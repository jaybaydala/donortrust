require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/quick_fact_sectors_controller'

# Re-raise errors caught by the controller.
class BusAdmin::QuickFactSectorsController; def rescue_action(e) raise e end; end

class BusAdmin::QuickFactSectorsControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_quick_fact_sectors

  def setup
    @controller = BusAdmin::QuickFactSectorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_quick_fact_sectors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_quick_fact_sector
    old_count = quick_fact_sector.count
    post :create, :quick_fact_sector => { }
    assert_equal old_count+1, quick_fact_sector.count
    
    assert_redirected_to quick_fact_sector_path(assigns(:quick_fact_sector))
  end

  def test_should_show_quick_fact_sector
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_quick_fact_sector
    put :update, :id => 1, :quick_fact_sector => { }
    assert_redirected_to quick_fact_sector_path(assigns(:quick_fact_sector))
  end
  
  def test_should_destroy_quick_fact_sector
    old_count = quick_fact_sector.count
    delete :destroy, :id => 1
    assert_equal old_count-1, quick_fact_sector.count
    
    assert_redirected_to bus_admin_quick_fact_sectors_path
  end
end
