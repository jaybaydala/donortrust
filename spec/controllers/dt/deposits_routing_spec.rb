require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::DepositsController do
  describe "route generation" do

    it "should map { :controller => 'dt/deposits', :action => 'index', :account_id => 1 } to /dt/accounts/1/deposits" do
      route_for(:controller => "dt/deposits", :action => "index", :account_id => 1).should == "/dt/accounts/1/deposits"
    end
  
    it "should map { :controller => 'dt/deposits', :action => 'new', :account_id => 1 } to /dt/accounts/1/deposits/new" do
      route_for(:controller => "dt/deposits", :action => "new", :account_id => 1).should == "/dt/accounts/1/deposits/new"
    end
  
    it "should map { :controller => 'dt/deposits', :action => 'show', :id => 1, :account_id => 1 } to /dt/accounts/1/deposits/1" do
      route_for(:controller => "dt/deposits", :action => "show", :id => 1, :account_id => 1).should == "/dt/accounts/1/deposits/1"
    end
  
    it "should map { :controller => 'dt/deposits', :action => 'edit', :id => 1, :account_id => 1 } to /dt/accounts/1/deposits/1/edit" do
      route_for(:controller => "dt/deposits", :action => "edit", :id => 1, :account_id => 1).should == "/dt/accounts/1/deposits/1/edit"
    end
  
    it "should map { :controller => 'dt/deposits', :action => 'update', :id => 1, :account_id => 1} to /dt/accounts/1/deposits/1" do
      route_for(:controller => "dt/deposits", :action => "update", :id => 1, :account_id => 1).should == "/dt/accounts/1/deposits/1"
    end
  
    it "should map { :controller => 'dt/deposits', :action => 'destroy', :id => 1, :account_id => 1} to /dt/accounts/1/deposits/1" do
      route_for(:controller => "dt/deposits", :action => "destroy", :id => 1, :account_id => 1).should == "/dt/accounts/1/deposits/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'dt/deposits', action => 'index', :account_id => '1' } from GET /dt/deposits" do
      params_from(:get, "/dt/accounts/1/deposits").should == {:controller => "dt/deposits", :action => "index", :account_id => "1"}
    end
  
    it "should generate params { :controller => 'dt/deposits', action => 'new', :account_id => '1' } from GET /dt/deposits/new" do
      params_from(:get, "/dt/accounts/1/deposits/new").should == {:controller => "dt/deposits", :action => "new", :account_id => "1"}
    end
  
    it "should generate params { :controller => 'dt/deposits', action => 'create', :account_id => '1' } from POST /dt/deposits" do
      params_from(:post, "/dt/accounts/1/deposits").should == {:controller => "dt/deposits", :action => "create", :account_id => "1"}
    end
  
    it "should generate params { :controller => 'dt/deposits', action => 'show', id => '1', :account_id => '1' } from GET /dt/deposits/1" do
      params_from(:get, "/dt/accounts/1/deposits/1").should == {:controller => "dt/deposits", :action => "show", :id => "1", :account_id => "1"}
    end
  
    it "should generate params { :controller => 'dt/deposits', action => 'edit', id => '1', :account_id => '1' } from GET /dt/deposits/1;edit" do
      params_from(:get, "/dt/accounts/1/deposits/1/edit").should == {:controller => "dt/deposits", :action => "edit", :id => "1", :account_id => "1"}
    end
  
    it "should generate params { :controller => 'dt/deposits', action => 'update', id => '1', :account_id => '1' } from PUT /dt/deposits/1" do
      params_from(:put, "/dt/accounts/1/deposits/1").should == {:controller => "dt/deposits", :action => "update", :id => "1", :account_id => "1"}
    end
  
    it "should generate params { :controller => 'dt/deposits', action => 'destroy', id => '1', :account_id => '1' } from DELETE /dt/deposits/1" do
      params_from(:delete, "/dt/accounts/1/deposits/1").should == {:controller => "dt/deposits", :action => "destroy", :id => "1", :account_id => "1"}
    end
  end
end