require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::GiftsController do
  describe "route generation" do

    it "should map { :controller => 'dt/gifts', :action => 'index' } to /dt/gifts" do
      route_for(:controller => "dt/gifts", :action => "index").should == "/dt/gifts"
    end
  
    it "should map { :controller => 'dt/gifts', :action => 'new' } to /dt/gifts/new" do
      route_for(:controller => "dt/gifts", :action => "new").should == "/dt/gifts/new"
    end

    it "should map { :controller => 'dt/gifts', :action => 'new', :format => :js } to /dt/gifts/new.js" do
      route_for(:controller => "dt/gifts", :action => "new", :format => :js).should == "/dt/gifts/new.js"
    end
  
    it "should map { :controller => 'dt/gifts', :action => 'show', :id => 1 } to /dt/gifts/1" do
      route_for(:controller => "dt/gifts", :action => "show", :id => 1).should == "/dt/gifts/1"
    end
  
    it "should map { :controller => 'dt/gifts', :action => 'edit', :id => 1 } to /dt/gifts/1/edit" do
      route_for(:controller => "dt/gifts", :action => "edit", :id => 1).should == "/dt/gifts/1/edit"
    end
  
    it "should map { :controller => 'dt/gifts', :action => 'update', :id => 1} to /dt/gifts/1" do
      route_for(:controller => "dt/gifts", :action => "update", :id => 1).should == "/dt/gifts/1"
    end
  
    it "should map { :controller => 'dt/gifts', :action => 'destroy', :id => 1} to /dt/gifts/1" do
      route_for(:controller => "dt/gifts", :action => "destroy", :id => 1).should == "/dt/gifts/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'dt/gifts', action => 'index' } from GET /dt/gifts" do
      params_from(:get, "/dt/gifts").should == {:controller => "dt/gifts", :action => "index"}
    end
  
    it "should generate params { :controller => 'dt/gifts', action => 'new' } from GET /dt/gifts/new" do
      params_from(:get, "/dt/gifts/new").should == {:controller => "dt/gifts", :action => "new"}
    end

    it "should generate params { :controller => 'dt/gifts', action => 'new', :format => 'js' } from GET /dt/gifts/new.js" do
      params_from(:get, "/dt/gifts/new.js").should == {:controller => "dt/gifts", :action => "new", :format => "js"}
    end
  
    it "should generate params { :controller => 'dt/gifts', action => 'create' } from POST /dt/gifts" do
      params_from(:post, "/dt/gifts").should == {:controller => "dt/gifts", :action => "create"}
    end
  
    it "should generate params { :controller => 'dt/gifts', action => 'show', id => '1' } from GET /dt/gifts/1" do
      params_from(:get, "/dt/gifts/1").should == {:controller => "dt/gifts", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/gifts', action => 'edit', id => '1' } from GET /dt/gifts/1;edit" do
      params_from(:get, "/dt/gifts/1/edit").should == {:controller => "dt/gifts", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/gifts', action => 'update', id => '1' } from PUT /dt/gifts/1" do
      params_from(:put, "/dt/gifts/1").should == {:controller => "dt/gifts", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'dt/gifts', action => 'destroy', id => '1' } from DELETE /dt/gifts/1" do
      params_from(:delete, "/dt/gifts/1").should == {:controller => "dt/gifts", :action => "destroy", :id => "1"}
    end
  end
end