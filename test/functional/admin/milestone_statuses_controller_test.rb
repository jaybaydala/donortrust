require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/milestone_statuses_controller'

# Re-raise errors caught by the controller.
class Admin::MilestoneStatusesController; def rescue_action(e) raise e end; end

class Admin::MilestoneStatusesControllerTest < Test::Unit::TestCase
  fixtures :milestone_statuses

  def setup
    @controller = Admin::MilestoneStatusesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    #hpd assert assigns(:milestone_statuses)
    #hpd assert assigns(:admin_milestone_statuses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_milestone_status
    old_count = MilestoneStatus.count
    post :create, :milestone_status => {
      :status => "xyzstatusxyz", :description => "status description" }
    assert_equal old_count+1, MilestoneStatus.count
    
    assert_redirected_to milestone_status_path(assigns(:milestone_status))
  end

  def test_should_show_milestone_status
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_milestone_status
    put :update, :id => 1, :milestone_status => { }
    assert_redirected_to milestone_status_path(assigns(:milestone_status))
  end
  
  def test_should_destroy_milestone_status
    old_count = MilestoneStatus.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MilestoneStatus.count
    
    assert_redirected_to milestone_statuses_path
  end
end
