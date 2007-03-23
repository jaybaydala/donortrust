require File.dirname(__FILE__) + '/../test_helper'
require 'village_groups_controller'

# Re-raise errors caught by the controller.
class VillageGroupsController; def rescue_action(e) raise e end; end

class VillageGroupsControllerTest < Test::Unit::TestCase
  fixtures :village_groups

  def setup
    @controller = VillageGroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:village_groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_village_group
    old_count = VillageGroup.count
    post :create, :village_group => { }
    assert_equal old_count+1, VillageGroup.count
    
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
    old_count = VillageGroup.count
    delete :destroy, :id => 1
    assert_equal old_count-1, VillageGroup.count
    
    assert_redirected_to village_groups_path
  end
end
