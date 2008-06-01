require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/millennium_goals_controller'

# Re-raise errors caught by the controller.
class BusAdmin::MillenniumGoalsController; def rescue_action(e) raise e end; end

class BusAdmin::MillenniumGoalsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_millennium_goals

  def setup
    @controller = BusAdmin::MillenniumGoalsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_millennium_goals)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_millennium_goal
    old_count = millennium_goal.count
    post :create, :millennium_goal => { }
    assert_equal old_count+1, millennium_goal.count
    
    assert_redirected_to millennium_goal_path(assigns(:millennium_goal))
  end

  def test_should_show_millennium_goal
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_millennium_goal
    put :update, :id => 1, :millennium_goal => { }
    assert_redirected_to millennium_goal_path(assigns(:millennium_goal))
  end
  
  def test_should_destroy_millennium_goal
    old_count = millennium_goal.count
    delete :destroy, :id => 1
    assert_equal old_count-1, millennium_goal.count
    
    assert_redirected_to bus_admin_millennium_goals_path
  end
end
