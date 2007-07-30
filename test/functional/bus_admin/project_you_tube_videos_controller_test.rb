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
  
  def test_should_create_project_you_tube_videos
    old_count = BusAdmin::ProjectYouTubeVideos.count
    post :create, :project_you_tube_videos => { }
    assert_equal old_count+1, BusAdmin::ProjectYouTubeVideos.count
    
    assert_redirected_to project_you_tube_videos_path(assigns(:project_you_tube_videos))
  end

  def test_should_show_project_you_tube_videos
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_project_you_tube_videos
    put :update, :id => 1, :project_you_tube_videos => { }
    assert_redirected_to project_you_tube_videos_path(assigns(:project_you_tube_videos))
  end
  
  def test_should_destroy_project_you_tube_videos
    old_count = BusAdmin::ProjectYouTubeVideos.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::ProjectYouTubeVideos.count
    
    assert_redirected_to bus_admin_project_you_tube_videos_path
  end
end
