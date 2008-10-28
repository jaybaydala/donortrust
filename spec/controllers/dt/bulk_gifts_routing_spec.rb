require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::BulkGiftsController do
  describe "route generation" do

    it "should map { :controller => 'dt/bulk_gifts', :action => 'index' } to /dt/bulk_gifts" do
      route_for(:controller => "dt/bulk_gifts", :action => "index").should == "/dt/bulk_gifts"
    end
  
    it "should map { :controller => 'dt/bulk_gifts', :action => 'new' } to /dt/bulk_gifts/new" do
      route_for(:controller => "dt/bulk_gifts", :action => "new").should == "/dt/bulk_gifts/new"
    end
  
    it "should map { :controller => 'dt/bulk_gifts', :action => 'show', :id => 1 } to /dt/bulk_gifts/1" do
      route_for(:controller => "dt/bulk_gifts", :action => "show", :id => 1).should == "/dt/bulk_gifts/1"
    end
  
    it "should map { :controller => 'dt/bulk_gifts', :action => 'edit', :id => 1 } to /dt/bulk_gifts/1/edit" do
      route_for(:controller => "dt/bulk_gifts", :action => "edit", :id => 1).should == "/dt/bulk_gifts/1/edit"
    end
  
    it "should map { :controller => 'dt/bulk_gifts', :action => 'update', :id => 1} to /dt/bulk_gifts/1" do
      route_for(:controller => "dt/bulk_gifts", :action => "update", :id => 1).should == "/dt/bulk_gifts/1"
    end
  
    it "should map { :controller => 'dt/bulk_gifts', :action => 'destroy', :id => 1} to /dt/bulk_gifts/1" do
      route_for(:controller => "dt/bulk_gifts", :action => "destroy", :id => 1).should == "/dt/bulk_gifts/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'dt/bulk_gifts', action => 'index' } from GET /dt/bulk_gifts" do
      params_from(:get, "/dt/bulk_gifts").should == {:controller => "dt/bulk_gifts", :action => "index"}
    end
  
    it "should generate params { :controller => 'dt/bulk_gifts', action => 'new' } from GET /dt/bulk_gifts/new" do
      params_from(:get, "/dt/bulk_gifts/new").should == {:controller => "dt/bulk_gifts", :action => "new"}
    end
  
    it "should generate params { :controller => 'dt/bulk_gifts', action => 'create' } from POST /dt/bulk_gifts" do
      params_from(:post, "/dt/bulk_gifts").should == {:controller => "dt/bulk_gifts", :action => "create"}
    end
  
    it "should generate params { :controller => 'dt/bulk_gifts', action => 'show', id => '1' } from GET /dt/bulk_gifts/1" do
      params_from(:get, "/dt/bulk_gifts/1").should == {:controller => "dt/bulk_gifts", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/bulk_gifts', action => 'edit', id => '1' } from GET /dt/bulk_gifts/1;edit" do
      params_from(:get, "/dt/bulk_gifts/1/edit").should == {:controller => "dt/bulk_gifts", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/bulk_gifts', action => 'update', id => '1' } from PUT /dt/bulk_gifts/1" do
      params_from(:put, "/dt/bulk_gifts/1").should == {:controller => "dt/bulk_gifts", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/bulk_gifts', action => 'destroy', id => '1' } from DELETE /dt/bulk_gifts/1" do
      params_from(:delete, "/dt/bulk_gifts/1").should == {:controller => "dt/bulk_gifts", :action => "destroy", :id => "1"}
    end
  end
end