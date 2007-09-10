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

context "Dt::Investments #route_for" do
  use_controller Dt::InvestmentsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should recognize the routes" do
    @rs.generate(:controller => "dt/investments", :action => "index").should.equal "/dt/investments"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'index' } to /dt/investments" do
    route_for(:controller => "dt/investments", :action => "index").should == "/dt/investments"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'show', :id => 1 } to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "show", :id => 1).should == "/dt/investments/1"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'new' } to /dt/investments/new" do
    route_for(:controller => "dt/investments", :action => "new").should == "/dt/investments/new"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'create' } to /dt/investments/new" do
    route_for(:controller => "dt/investments", :action => "new").should == "/dt/investments/new"
  end
    
  specify "should map { :controller => 'dt/investments', :action => 'edit', :id => 1 } to /dt/investments/1;edit" do
    route_for(:controller => "dt/investments", :action => "edit", :id => 1).should == "/dt/investments/1;edit"
    #dt_edit_deposit_path(1).should.not.throw
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'update', :id => 1} to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "update", :id => 1).should == "/dt/investments/1"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'destroy', :id => 1} to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "destroy", :id => 1).should == "/dt/investments/1"
  end

  specify "should map { :controller => 'dt/investments', :action => 'confirm'} to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "confirm").should == "/dt/investments;confirm"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "" do
  use_controller Dt::InvestmentsController
  fixtures :investments, :users, :projects, :groups
  
  specify "truth" do
    true.should.be true
  end
end