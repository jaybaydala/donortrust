require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/gifts_controller'

# Re-raise errors caught by the controller.
class Dt::GiftsController; def rescue_action(e) raise e end; end

context "Dt::Gifts inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::GiftsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "placeholder" do
  fixtures :gifts, :users
  
  setup do
    @controller = Dt::GiftsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "truth" do
    true.should.be true
  end
end