require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/milestones_controller'

# Re-raise errors caught by the controller.
class BusAdmin::MilestonesController; def rescue_action(e) raise e end; end

class BusAdmin::MilestonesControllerTest < ActiveSupport::TestCase
  fixtures :milestones

  def setup
    @controller = BusAdmin::MilestonesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_milestones)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_milestone
    old_count = Milestone.count
    post :create, :milestone => { }
    assert_equal old_count+1, Milestone.count
    
    assert_redirected_to milestone_path(assigns(:milestone))
  end

  def test_should_show_milestone
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_milestone
    put :update, :id => 1, :milestone => { }
    assert_redirected_to milestone_path(assigns(:milestone))
  end
  
  def test_should_destroy_milestone
    old_count = Milestone.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Milestone.count
    
    assert_redirected_to bus_admin_milestones_path
  end
end