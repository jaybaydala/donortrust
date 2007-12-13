require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/mdgs_controller'

# Re-raise errors caught by the controller.
class Dt::MdgsController; def rescue_action(e) raise e end; end

context "Dt::MdgsController inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::MdgsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::MdgsController #route_for" do
  use_controller Dt::MdgsController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/projects', :action => 'index' } to /dt/projects" do
    route_for(:controller => "dt/projects", :action => "index").should == "/dt/projects"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'show', :id => 1 } to /dt/projects/1" do
    route_for(:controller => "dt/projects", :action => "show", :id => 1).should == "/dt/projects/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::MdgsController index behaviour" do
  use_controller Dt::MdgsController
  
  specify "should assign @goals" do
    mdg1 = MillenniumGoal.new(:name => 'goal 1')
    mdg2 = MillenniumGoal.new(:name => 'goal 2')
    MillenniumGoal.stubs(:find).with(:all).returns([mdg1, mdg2])
    get :index
    assigns(:goals).should.not.be.nil
  end
end

context "Dt::MdgsController show behaviour" do
  use_controller Dt::MdgsController
  
  specify "should assign @goal" do
    mdg1 = MillenniumGoal.new(:name => 'goal 1')
    MillenniumGoal.stubs(:find).returns(mdg1)
    get :show, :id => 1
    assigns(:goal).should.not.be.nil
  end

  specify "should use the correct template" do
    mdg1 = MillenniumGoal.new(:name => 'goal 1')
    MillenniumGoal.stubs(:find).returns(mdg1)
    get :show, :id => 1
    template.should.be 'dt/mdgs/show'
  end
end
