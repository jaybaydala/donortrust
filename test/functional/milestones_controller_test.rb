require File.dirname(__FILE__) + '/../test_helper'
require 'milestones_controller'

# Re-raise errors caught by the controller.
class MilestonesController; def rescue_action(e) raise e end; end

class MilestonesControllerTest < Test::Unit::TestCase
  fixtures :projects, :measures, :milestone_categories, :milestone_statuses, :milestones

  def setup
    @controller = MilestonesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :project_id => projects( :project_one )
    assert_response :success
    assert assigns(:milestones)
  end

  def test_should_get_new
    get :new, :project_id => projects( :project_one )
    assert_response :success
  end
  
  def test_should_create_milestone
    old_count = Milestone.count
    post :create, 
      :project_id => projects( :project_one ),
      :milestone => {
        :project_id => projects( :project_one ),
        :milestone_category_id => milestone_categories( :testone ),
        :milestone_status_id => milestone_statuses( :proposed ),
        :measure_id => measures( :testone ),
        :description => "enough description to be valid" }
    assert_equal old_count+1, Milestone.count
    
    assert_redirected_to milestone_path( projects( :project_one ), assigns(:milestone))
  end

  def test_should_show_milestone
    get :show, :id => milestones( :one ), :project_id => projects( :project_one )
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => milestones( :one ), :project_id => projects( :project_one )
    assert_response :success
  end
  
  def test_should_update_milestone
    put :update, :id => milestones( :one ), :milestone => { }, :project_id => projects( :project_one )
    assert_redirected_to milestone_path( projects( :project_one ), assigns(:milestone))
  end
  
  def test_should_destroy_milestone
    old_count = Milestone.count
    delete :destroy, :id => milestones( :one ), :project_id => projects( :project_one )
    assert_equal old_count-1, Milestone.count
    
    assert_redirected_to milestones_path( projects( :project_one ))
  end
end
