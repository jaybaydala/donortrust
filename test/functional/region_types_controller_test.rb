require File.dirname(__FILE__) + '/../test_helper'
require 'region_types_controller'

# Re-raise errors caught by the controller.
class RegionTypesController; def rescue_action(e) raise e end; end

class RegionTypesControllerTest < Test::Unit::TestCase
  fixtures :region_types

  def setup
    @controller = RegionTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:region_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_region_type
    old_count = RegionType.count
    post :create, :region_type => { :region_type_name => "junktype" }
    assert_equal old_count+1, RegionType.count
    
    assert_redirected_to region_type_path(assigns(:region_type))
  end

  def test_should_show_region_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_region_type
    put :update, :id => 1, :region_type => { }
    assert_redirected_to region_type_path(assigns(:region_type))
  end
  
  def test_should_destroy_region_type
    old_count = RegionType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, RegionType.count
    
    assert_redirected_to region_types_path
  end
end
