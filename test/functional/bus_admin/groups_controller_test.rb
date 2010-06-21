require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/groups_controller'

# Re-raise errors caught by the controller.
class BusAdmin::GroupsController; def rescue_action(e) raise e end; end

class BusAdmin::GroupsControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_groups

  def setup
    @controller = BusAdmin::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_group
    old_count = group.count
    post :create, :group => { }
    assert_equal old_count+1, group.count
    
    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_show_group
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_group
    put :update, :id => 1, :group => { }
    assert_redirected_to group_path(assigns(:group))
  end
  
  def test_should_destroy_group
    old_count = group.count
    delete :destroy, :id => 1
    assert_equal old_count-1, group.count
    
    assert_redirected_to bus_admin_groups_path
  end
end
