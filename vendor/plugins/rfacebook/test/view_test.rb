require File.dirname(__FILE__) + "/test_helper"
require "test/unit"
require "rubygems"
require "mocha"

class ViewTest < Test::Unit::TestCase
  
  def test_extensions_are_present
    assert @view.respond_to?(:in_facebook_canvas?)
    assert @view.respond_to?(:in_facebook_frame?)
    assert @view.respond_to?(:in_mock_ajax?)
    assert @view.respond_to?(:fbparams)
    assert @view.respond_to?(:fbsession)
    assert @view.respond_to?(:image_path)
    assert @view.respond_to?(:facebook_debug_panel)
  end

  def test_image_path_should_not_rewrite_absolute_urls
    # TODO: implement test
  end
  
  def setup
    @controller = DummyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @view = ActionView::Base.allocate # TODO: how do we unit test views in Rails?
  end
    
end

