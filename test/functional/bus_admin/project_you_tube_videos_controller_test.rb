require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/project_you_tube_videos_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ProjectYouTubeVideosController; def rescue_action(e) raise e end; end

class BusAdmin::ProjectYouTubeVideosControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_project_you_tube_videos

  def setup
    @controller = BusAdmin::ProjectYouTubeVideosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_project_you_tube_videos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_project_you_tube_video
    old_count = project_you_tube_video.count
    post :create, :project_you_tube_video => { }
    assert_equal old_count+1, project_you_tube_video.count
    
    assert_redirected_to project_you_tube_video_path(assigns(:project_you_tube_video))
  end

  def test_should_show_project_you_tube_video
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_project_you_tube_video
    put :update, :id => 1, :project_you_tube_video => { }
    assert_redirected_to project_you_tube_video_path(assigns(:project_you_tube_video))
  end
  
  def test_should_destroy_project_you_tube_video
    old_count = project_you_tube_video.count
    delete :destroy, :id => 1
    assert_equal old_count-1, project_you_tube_video.count
    
    assert_redirected_to bus_admin_project_you_tube_videos_path
  end
end
