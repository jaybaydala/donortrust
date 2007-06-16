require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/rss_feed_elements_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RssFeedElementsController; def rescue_action(e) raise e end; end

class BusAdmin::RssFeedElementsControllerTest < Test::Unit::TestCase
  fixtures :bus_admin_rss_feed_elements

  def setup
    @controller = BusAdmin::RssFeedElementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_rss_feed_elements)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_rss_feed_element
    old_count = BusAdmin::RssFeedElement.count
    post :create, :rss_feed_element => { }
    assert_equal old_count+1, BusAdmin::RssFeedElement.count
    
    assert_redirected_to rss_feed_element_path(assigns(:rss_feed_element))
  end

  def test_should_show_rss_feed_element
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_rss_feed_element
    put :update, :id => 1, :rss_feed_element => { }
    assert_redirected_to rss_feed_element_path(assigns(:rss_feed_element))
  end
  
  def test_should_destroy_rss_feed_element
    old_count = BusAdmin::RssFeedElement.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::RssFeedElement.count
    
    assert_redirected_to bus_admin_rss_feed_elements_path
  end
end
