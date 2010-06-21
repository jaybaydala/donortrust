require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/quick_fact_types_controller'

# Re-raise errors caught by the controller.
class BusAdmin::QuickFactTypesController; def rescue_action(e) raise e end; end

class BusAdmin::QuickFactTypesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_quick_fact_types

  def setup
    @controller = BusAdmin::QuickFactTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_quick_fact_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_quick_fact_type
    old_count = quick_fact_type.count
    post :create, :quick_fact_type => { }
    assert_equal old_count+1, quick_fact_type.count
    
    assert_redirected_to quick_fact_type_path(assigns(:quick_fact_type))
  end

  def test_should_show_quick_fact_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_quick_fact_type
    put :update, :id => 1, :quick_fact_type => { }
    assert_redirected_to quick_fact_type_path(assigns(:quick_fact_type))
  end
  
  def test_should_destroy_quick_fact_type
    old_count = quick_fact_type.count
    delete :destroy, :id => 1
    assert_equal old_count-1, quick_fact_type.count
    
    assert_redirected_to bus_admin_quick_fact_types_path
  end
end
