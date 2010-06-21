require File.dirname(__FILE__) + '/../../test_helper'
require 'bus_admin/rss_feeds_controller'

# Re-raise errors caught by the controller.
class BusAdmin::RSSFeedsController; def rescue_action(e) raise e end; end

class BusAdmin::RSSFeedsControllerTest < ActiveSupport::TestCase
  fixtures :bus_admin_rss_feeds

  def setup
    @controller = BusAdmin::RSSFeedsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:bus_admin_rss_feeds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_rss_feed
    old_count = BusAdmin::RSSFeed.count
    post :create, :rss_feed => { }
    assert_equal old_count+1, BusAdmin::RSSFeed.count
    
    assert_redirected_to rss_feed_path(assigns(:rss_feed))
  end

  def test_should_show_rss_feed
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_rss_feed
    put :update, :id => 1, :rss_feed => { }
    assert_redirected_to rss_feed_path(assigns(:rss_feed))
  end
  
  def test_should_destroy_rss_feed
    old_count = BusAdmin::RSSFeed.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BusAdmin::RSSFeed.count
    
    assert_redirected_to bus_admin_rss_feeds_path
  end
end
