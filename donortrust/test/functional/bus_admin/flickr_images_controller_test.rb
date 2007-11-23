require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/flickr_images_controller'

# Re-raise errors caught by the controller.
class BusAdmin::FlickrImagesController; def rescue_action(e) raise e end; end

class BusAdmin::FlickrImagesControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_flickr_images

  def setup
    @controller = BusAdmin::FlickrImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_flickr_images)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_flickr_image
    old_count = BusAdmin::FlickrImage.count
    post :create, :flickr_image => { }
    assert_equal old_count+1, BusAdmin::FlickrImage.count
    
    assert_redirected_to flickr_image_path(assigns(:flickr_image))
  end

  def test_should_show_flickr_image
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_flickr_image
    put :update, :id => 1, :flickr_image => { }
    assert_redirected_to flickr_image_path(assigns(:flickr_image))
  end
  
  def test_should_destroy_flickr_image
    old_count = BusAdmin::FlickrImage.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::FlickrImage.count
    
    assert_redirected_to bus_admin_flickr_images_path
  end
end
