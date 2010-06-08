require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/banner_images_controller'

# Re-raise errors caught by the controller.
class BusAdmin::BannerImagesController; def rescue_action(e) raise e end; end

class BusAdmin::BannerImagesControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_banner_images

  def setup
    @controller = BusAdmin::BannerImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_banner_images)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_banner_image
    old_count = banner_image.count
    post :create, :banner_image => { }
    assert_equal old_count+1, banner_image.count
    
    assert_redirected_to banner_image_path(assigns(:banner_image))
  end

  def test_should_show_banner_image
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_banner_image
    put :update, :id => 1, :banner_image => { }
    assert_redirected_to banner_image_path(assigns(:banner_image))
  end
  
  def test_should_destroy_banner_image
    old_count = banner_image.count
    delete :destroy, :id => 1
    assert_equal old_count-1, banner_image.count
    
    assert_redirected_to bus_admin_banner_images_path
  end
end
