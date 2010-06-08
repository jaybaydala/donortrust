require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/project_flickr_images_controller'

# Re-raise errors caught by the controller.
class BusAdmin::ProjectFlickrImagesController; def rescue_action(e) raise e end; end

class BusAdmin::ProjectFlickrImagesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_project_flickr_images

  def setup
    @controller = BusAdmin::ProjectFlickrImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_project_flickr_images)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_project_flickr_images
    old_count = BusAdmin::ProjectFlickrImages.count
    post :create, :project_flickr_images => { }
    assert_equal old_count+1, BusAdmin::ProjectFlickrImages.count
    
    assert_redirected_to project_flickr_images_path(assigns(:project_flickr_images))
  end

  def test_should_show_project_flickr_images
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_project_flickr_images
    put :update, :id => 1, :project_flickr_images => { }
    assert_redirected_to project_flickr_images_path(assigns(:project_flickr_images))
  end
  
  def test_should_destroy_project_flickr_images
    old_count = BusAdmin::ProjectFlickrImages.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::ProjectFlickrImages.count
    
    assert_redirected_to bus_admin_project_flickr_images_path
  end
end
