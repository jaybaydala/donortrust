require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/deposits_controller'

# Re-raise errors caught by the controller.
class Dt::DepositsController; def rescue_action(e) raise e end; end

context "Dt::Deposits inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::DepositsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "placeholder" do
  fixtures :user_transactions, :users
  
  setup do
    @controller = Dt::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "truth" do
    true.should.be true
  end
end