require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/village_groups_controller'

# Re-raise errors caught by the controller.
class BusAdmin::VillageGroupsController; def rescue_action(e) raise e end; end

class BusAdmin::VillageGroupsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_village_groups

  def setup
    @controller = BusAdmin::VillageGroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_village_groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_village_group
    old_count = BusAdmin::VillageGroup.count
    post :create, :village_group => { }
    assert_equal old_count+1, BusAdmin::VillageGroup.count
    
    assert_redirected_to village_group_path(assigns(:village_group))
  end

  def test_should_show_village_group
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_village_group
    put :update, :id => 1, :village_group => { }
    assert_redirected_to village_group_path(assigns(:village_group))
  end
  
  def test_should_destroy_village_group
    old_count = BusAdmin::VillageGroup.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::VillageGroup.count
    
    assert_redirected_to bus_admin_village_groups_path
  end
end
