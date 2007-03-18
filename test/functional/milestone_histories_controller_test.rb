require File.dirname(__FILE__) + '/../test_helper'
require 'milestone_histories_controller'

# Re-raise errors caught by the controller.
class MilestoneHistoriesController; def rescue_action(e) raise e end; end

class MilestoneHistoriesControllerTest < Test::Unit::TestCase
  fixtures :milestone_histories

  def setup
    @controller = MilestoneHistoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:milestone_histories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_milestone_history
    old_count = MilestoneHistory.count
    post :create, :milestone_history => { }
    assert_equal old_count+1, MilestoneHistory.count
    
    assert_redirected_to milestone_history_path(assigns(:milestone_history))
  end

  def test_should_show_milestone_history
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_milestone_history
    put :update, :id => 1, :milestone_history => { }
    assert_redirected_to milestone_history_path(assigns(:milestone_history))
  end
  
  def test_should_destroy_milestone_history
    old_count = MilestoneHistory.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MilestoneHistory.count
    
    assert_redirected_to milestone_histories_path
  end
end
