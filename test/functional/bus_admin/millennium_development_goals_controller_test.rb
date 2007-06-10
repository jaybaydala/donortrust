require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/millennium_development_goals_controller'

# Re-raise errors caught by the controller.
class BusAdmin::MillenniumDevelopmentGoalsController; def rescue_action(e) raise e end; end

class BusAdmin::MillenniumDevelopmentGoalsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_millennium_development_goals

  def setup
    @controller = BusAdmin::MillenniumDevelopmentGoalsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_millennium_development_goals)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_millennium_development_goal
    old_count = BusAdmin::MillenniumDevelopmentGoal.count
    post :create, :millennium_development_goal => { }
    assert_equal old_count+1, BusAdmin::MillenniumDevelopmentGoal.count
    
    assert_redirected_to millennium_development_goal_path(assigns(:millennium_development_goal))
  end

  def test_should_show_millennium_development_goal
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_millennium_development_goal
    put :update, :id => 1, :millennium_development_goal => { }
    assert_redirected_to millennium_development_goal_path(assigns(:millennium_development_goal))
  end
  
  def test_should_destroy_millennium_development_goal
    old_count = BusAdmin::MillenniumDevelopmentGoal.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::MillenniumDevelopmentGoal.count
    
    assert_redirected_to bus_admin_millennium_development_goals_path
  end
end
