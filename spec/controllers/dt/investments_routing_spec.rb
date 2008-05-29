require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::InvestmentsController do
  describe "route generation" do

    it "should map { :controller => 'dt/investments', :action => 'index' } to /dt/investments" do
      route_for(:controller => "dt/investments", :action => "index").should == "/dt/investments"
    end
  
    it "should map { :controller => 'dt/investments', :action => 'new' } to /dt/investments/new" do
      route_for(:controller => "dt/investments", :action => "new").should == "/dt/investments/new"
    end
  
    it "should map { :controller => 'dt/investments', :action => 'show', :id => 1 } to /dt/investments/1" do
      route_for(:controller => "dt/investments", :action => "show", :id => 1).should == "/dt/investments/1"
    end
  
    it "should map { :controller => 'dt/investments', :action => 'edit', :id => 1 } to /dt/investments/1/edit" do
      route_for(:controller => "dt/investments", :action => "edit", :id => 1).should == "/dt/investments/1/edit"
    end
  
    it "should map { :controller => 'dt/investments', :action => 'update', :id => 1} to /dt/investments/1" do
      route_for(:controller => "dt/investments", :action => "update", :id => 1).should == "/dt/investments/1"
    end
  
    it "should map { :controller => 'dt/investments', :action => 'destroy', :id => 1} to /dt/investments/1" do
      route_for(:controller => "dt/investments", :action => "destroy", :id => 1).should == "/dt/investments/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'dt/investments', action => 'index' } from GET /dt/investments" do
      params_from(:get, "/dt/investments").should == {:controller => "dt/investments", :action => "index"}
    end
  
    it "should generate params { :controller => 'dt/investments', action => 'new' } from GET /dt/investments/new" do
      params_from(:get, "/dt/investments/new").should == {:controller => "dt/investments", :action => "new"}
    end
  
    it "should generate params { :controller => 'dt/investments', action => 'create' } from POST /dt/investments" do
      params_from(:post, "/dt/investments").should == {:controller => "dt/investments", :action => "create"}
    end
  
    it "should generate params { :controller => 'dt/investments', action => 'show', id => '1' } from GET /dt/investments/1" do
      params_from(:get, "/dt/investments/1").should == {:controller => "dt/investments", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/investments', action => 'edit', id => '1' } from GET /dt/investments/1;edit" do
      params_from(:get, "/dt/investments/1/edit").should == {:controller => "dt/investments", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/investments', action => 'update', id => '1' } from PUT /dt/investments/1" do
      params_from(:put, "/dt/investments/1").should == {:controller => "dt/investments", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/investments', action => 'destroy', id => '1' } from DELETE /dt/investments/1" do
      params_from(:delete, "/dt/investments/1").should == {:controller => "dt/investments", :action => "destroy", :id => "1"}
    end
  end
end