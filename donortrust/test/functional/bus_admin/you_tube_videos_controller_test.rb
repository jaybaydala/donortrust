require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/you_tube_videos_controller'

# Re-raise errors caught by the controller.
class BusAdmin::YouTubeVideosController; def rescue_action(e) raise e end; end

class BusAdmin::YouTubeVideosControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_you_tube_videos

  def setup
    @controller = BusAdmin::YouTubeVideosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_you_tube_videos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_you_tube_video
    old_count = BusAdmin::YouTubeVideo.count
    post :create, :you_tube_video => { }
    assert_equal old_count+1, BusAdmin::YouTubeVideo.count
    
    assert_redirected_to you_tube_video_path(assigns(:you_tube_video))
  end

  def test_should_show_you_tube_video
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_you_tube_video
    put :update, :id => 1, :you_tube_video => { }
    assert_redirected_to you_tube_video_path(assigns(:you_tube_video))
  end
  
  def test_should_destroy_you_tube_video
    old_count = BusAdmin::YouTubeVideo.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::YouTubeVideo.count
    
    assert_redirected_to bus_admin_you_tube_videos_path
  end
end
