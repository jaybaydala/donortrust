require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/budget_items_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BudgetItemsController; def rescue_action(e) raise e end; end

class BusAdmin::BudgetItemsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_budget_items

  def setup
    @controller = BusAdmin::BudgetItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_budget_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_budget_item
    old_count = budget_item.count
    post :create, :budget_item => { }
    assert_equal old_count+1, budget_item.count
    
    assert_redirected_to budget_item_path(assigns(:budget_item))
  end

  def test_should_show_budget_item
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_budget_item
    put :update, :id => 1, :budget_item => { }
    assert_redirected_to budget_item_path(assigns(:budget_item))
  end
  
  def test_should_destroy_budget_item
    old_count = budget_item.count
    delete :destroy, :id => 1
    assert_equal old_count-1, budget_item.count
    
    assert_redirected_to bus_admin_budget_items_path
  end
end
