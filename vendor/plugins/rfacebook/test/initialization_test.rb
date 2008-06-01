require File.dirname(__FILE__) + "/test_helper"
require "test/unit"
require "rubygems"
require "mocha"

class InitializationTest < Test::Unit::TestCase
  
  def setup
    @controller = DummyController.new
  end
  
  def test_yml_loaded_properly
    assert FACEBOOK["key"]
    assert FACEBOOK["secret"]
  end
  
  def test_controller_paths_for_canvas_apps_are_relative
    if FACEBOOK["canvas_path"]
      assert(/^\/(.*)\/$/.match(@controller.facebook_canvas_path), "canvas_path should be relative (check your facebook.yml)")
    end
    
    if FACEBOOK["callback_path"]
      assert(/^\/(.*)\/$/.match(@controller.facebook_callback_path), "callback_path should be relative (check your facebook.yml)")
    end
  end
    
end

