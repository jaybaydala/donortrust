require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require "action_controller/test_process"
require "action_controller/integration"

# helpers for all RFacebook unit tests
class Test::Unit::TestCase
  
  def assert_rfacebook_overrides_method(object, methodSymbol)
    # by convention, RFacebook uses the alias_method_chain on certain methods
    rfacebookMethodSymbol = "#{methodSymbol}_with_rfacebook".to_sym
    aliasedMethodSymbol = "#{methodSymbol}_without_rfacebook".to_sym
    
    # string description of this object
    objectDescription = object.is_a?(Class) ? object.to_s : object.class.to_s
    
    # ensure that the original method is still available
    assert object.respond_to?(aliasedMethodSymbol, true), "Could not find original #{objectDescription}::#{methodSymbol}"
    
    # ensure that the object has the RFacebook override
    assert object.respond_to?(rfacebookMethodSymbol, true), "Could not find RFacebook override of #{objectDescription}::#{methodSymbol}"
    
    # ensure that the override is actually overriding the given method
    assert object.method(methodSymbol) == object.method(rfacebookMethodSymbol), "#{objectDescription}::#{methodSymbol} does not appear to be overridden by RFacebook"
  end
  
end

# dummy controller used in many test cases
class DummyController < ActionController::Base
  
  before_filter :require_facebook_login, :only => [:index]
  
  # actions
  def index
    render :text => "viewing index"
  end
    
  def nofilter
    render :text => "no filter needed"
  end
  
  def shouldbeinstalled
    if require_facebook_install
      render :text => "app is installed"
    end
  end
  
  def doredirect
    redirect_to params[:redirect_url]
  end
  
  def render_foobar_action_on_callback
    render :text => url_for("#{facebook_callback_path}foobar")
  end
  
  
  # utility methods
  
  def rescue_action(e) 
    raise e 
  end
  
  
  def stub_fbparams(overriddenOptions={})
    self.stubs(:fbparams).returns({
      "session_key" => "12345",
      "user" => "9876",
      "expires" => Time.now.to_i*2, # timeout long in the future
      "time" => Time.now.to_i*2, # timeout long in the future
    }.merge(overriddenOptions))
  end
    
  def simulate_inside_canvas(moreParams={})
    self.stub_fbparams({"in_canvas"=>"1"})
    @extra_params = {"fb_sig_in_canvas"=>"1"}.merge(moreParams)
  end
  
  def params
    if @extra_params
      (super || {}).merge(@extra_params)
    else
      super
    end
  end
  
  # for external apps
  def finish_facebook_login
    render :text => "finished facebook login"
  end
  
end

# dummy model used in a few test cases
class DummyModel < ActiveRecord::Base
  acts_as_facebook_user
  
  def facebook_uid
    "dummyuid"
  end
  
  def facebook_session_key
    "dummysessionkey"
  end
end

