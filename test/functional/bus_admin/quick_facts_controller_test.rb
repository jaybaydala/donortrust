require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/quick_facts_controller'

# Re-raise errors caught by the controller.
class BusAdmin::QuickFactsController; def rescue_action(e) raise e end; end

class BusAdmin::QuickFactsControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_quick_facts

  def setup
    @controller = BusAdmin::QuickFactsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_quick_facts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_quick_fact
    old_count = quick_fact.count
    post :create, :quick_fact => { }
    assert_equal old_count+1, quick_fact.count
    
    assert_redirected_to quick_fact_path(assigns(:quick_fact))
  end

  def test_should_show_quick_fact
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_quick_fact
    put :update, :id => 1, :quick_fact => { }
    assert_redirected_to quick_fact_path(assigns(:quick_fact))
  end
  
  def test_should_destroy_quick_fact
    old_count = quick_fact.count
    delete :destroy, :id => 1
    assert_equal old_count-1, quick_fact.count
    
    assert_redirected_to bus_admin_quick_facts_path
  end
end
