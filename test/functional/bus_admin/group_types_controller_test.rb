require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/group_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::GroupTypesController; def rescue_action(e) raise e end; end

class BusAdmin::GroupTypesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_group_types

  def setup
    @controller = BusAdmin::GroupTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_group_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_group_type
    old_count = group_type.count
    post :create, :group_type => { }
    assert_equal old_count+1, group_type.count
    
    assert_redirected_to group_type_path(assigns(:group_type))
  end

  def test_should_show_group_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_group_type
    put :update, :id => 1, :group_type => { }
    assert_redirected_to group_type_path(assigns(:group_type))
  end
  
  def test_should_destroy_group_type
    old_count = group_type.count
    delete :destroy, :id => 1
    assert_equal old_count-1, group_type.count
    
    assert_redirected_to bus_admin_group_types_path
  end
end
