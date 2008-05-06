require File.dirname(__FILE__) + "/test_helper"
require "test/unit"
require "rubygems"
require "mocha"

class SessionTest < Test::Unit::TestCase
  
  def setup
    @controller = DummyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @cgi_session_placeholder = CGI::Session.allocate
    
    # RFacebook extends a certain subset of Rails session stores,
    # so we must test them each individually
    @sessionStoresToTest = [
      CGI::Session::PStore,
      CGI::Session::ActiveRecordStore,
      CGI::Session::DRbStore,
      CGI::Session::FileStore,
      CGI::Session::MemoryStore
    ]
    
    begin
      # optionally check MemCacheStore (only if memcache-client is installed)
      @sessionStoresToTest << CGI::Session::MemCacheStore
    rescue Exception => e
    end
    
  end
  
  def test_cgi_session_helpers_are_present
    @cgi_session_placeholder.respond_to?(:force_to_be_new!, true)
    @cgi_session_placeholder.respond_to?(:using_facebook_session_id?, true)
  end
  
  def test_cgi_session_overrides_are_present    
    assert_rfacebook_overrides_method(@cgi_session_placeholder, :initialize)
    assert_rfacebook_overrides_method(@cgi_session_placeholder, :new_session)    
  end
  
  def test_session_store_overrides_are_present
    # assert that each of the extended stores has the special RFacebook overrides
    # that enable session storage when inside the canvas
    @sessionStoresToTest.each do |storeKlass|
      assert_rfacebook_overrides_method(storeKlass.allocate, :initialize)
    end
  end
  
  def test_cgi_session_grabs_fb_sig_session_key
    # TODO: implement test
  end
  
  def test_session_store_uses_overridden_init_method_when_in_canvas
    # TODO: implement test
  end
  
  def test_session_store_uses_original_init_method_when_not_in_canvas
    # TODO: implement test
  end
  
end

