require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/urban_centres_controller'

# Re-raise errors caught by the controller.
class BusAdmin::UrbanCentresController; def rescue_action(e) raise e end; end

class BusAdmin::UrbanCentresControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_urban_centres

  def setup
    @controller = BusAdmin::UrbanCentresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_urban_centres)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_urban_centre
    old_count = BusAdmin::UrbanCentre.count
    post :create, :urban_centre => { }
    assert_equal old_count+1, BusAdmin::UrbanCentre.count
    
    assert_redirected_to urban_centre_path(assigns(:urban_centre))
  end

  def test_should_show_urban_centre
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_urban_centre
    put :update, :id => 1, :urban_centre => { }
    assert_redirected_to urban_centre_path(assigns(:urban_centre))
  end
  
  def test_should_destroy_urban_centre
    old_count = BusAdmin::UrbanCentre.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::UrbanCentre.count
    
    assert_redirected_to bus_admin_urban_centres_path
  end
end
