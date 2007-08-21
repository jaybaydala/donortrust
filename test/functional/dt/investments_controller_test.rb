require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/investments_controller'

# Re-raise errors caught by the controller.
class Dt::InvestmentsController; def rescue_action(e) raise e end; end

context "Dt::Investments inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::InvestmentsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "placeholder" do
  fixtures :investments, :users, :projects, :groups
  
  setup do
    @controller = Dt::InvestmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "truth" do
    true.should.be true
  end
end