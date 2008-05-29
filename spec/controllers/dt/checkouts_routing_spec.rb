require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CheckoutsController do
  describe "route generation" do

    it "should map { :controller => 'dt/checkouts', :action => 'new' } to /dt/checkout/new" do
      route_for(:controller => "dt/checkouts", :action => "new").should == "/dt/checkout/new"
    end
  
    it "should map { :controller => 'dt/checkouts', :action => 'show' } to /dt/checkout" do
      route_for(:controller => "dt/checkouts", :action => "show").should == "/dt/checkout"
    end
  
    it "should map { :controller => 'dt/checkouts', :action => 'edit' } to /dt/checkout/edit" do
      route_for(:controller => "dt/checkouts", :action => "edit").should == "/dt/checkout/edit"
    end
  
    it "should map { :controller => 'dt/checkouts', :action => 'update'} to /dt/checkout" do
      route_for(:controller => "dt/checkouts", :action => "update").should == "/dt/checkout"
    end
  
    it "should map { :controller => 'dt/checkouts', :action => 'destroy'} to /dt/checkout" do
      route_for(:controller => "dt/checkouts", :action => "destroy").should == "/dt/checkout"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'dt/checkouts', action => 'new' } from GET /dt/checkout/new" do
      params_from(:get, "/dt/checkout/new").should == {:controller => "dt/checkouts", :action => "new"}
    end
  
    it "should generate params { :controller => 'dt/checkouts', action => 'create' } from POST /dt/checkout" do
      params_from(:post, "/dt/checkout").should == {:controller => "dt/checkouts", :action => "create"}
    end
  
    it "should generate params { :controller => 'dt/checkouts', action => 'show' } from GET /dt/checkout" do
      params_from(:get, "/dt/checkout").should == {:controller => "dt/checkouts", :action => "show"}
    end
  
    it "should generate params { :controller => 'dt/checkouts', action => 'edit' } from GET /dt/checkout/edit" do
      params_from(:get, "/dt/checkout/edit").should == {:controller => "dt/checkouts", :action => "edit"}
    end
  
    it "should generate params { :controller => 'dt/checkouts', action => 'update' } from PUT /dt/checkout" do
      params_from(:put, "/dt/checkout").should == {:controller => "dt/checkouts", :action => "update"}
    end
  
    it "should generate params { :controller => 'dt/checkouts', action => 'destroy' } from DELETE /dt/checkout" do
      params_from(:delete, "/dt/checkout").should == {:controller => "dt/checkouts", :action => "destroy"}
    end
  end
end