require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/place_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::PlaceTypesController; def rescue_action(e) raise e end; end

class BusAdmin::PlaceTypesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_place_types

  def setup
    @controller = BusAdmin::PlaceTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_place_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_place_type
    old_count = place_type.count
    post :create, :place_type => { }
    assert_equal old_count+1, place_type.count
    
    assert_redirected_to place_type_path(assigns(:place_type))
  end

  def test_should_show_place_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_place_type
    put :update, :id => 1, :place_type => { }
    assert_redirected_to place_type_path(assigns(:place_type))
  end
  
  def test_should_destroy_place_type
    old_count = place_type.count
    delete :destroy, :id => 1
    assert_equal old_count-1, place_type.count
    
    assert_redirected_to bus_admin_place_types_path
  end
end
