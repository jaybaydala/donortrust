require File.dirname(__FILE__) + '/../test_helper'

class BudgetItemRoutingTest < Test::Unit::TestCase
  
  def test_routing_options_generates_restful_path
    assert_generates( "/bus_admin/budget_items", :controller => "bus_admin/budget_items", :action => "index" )
    assert_generates( "/bus_admin/budget_items", { :controller => "bus_admin/budget_items", :action => "create" } )
    assert_generates( "/bus_admin/budget_items/new", { :controller => "bus_admin/budget_items", :action => "new" } )
    assert_generates( "/bus_admin/budget_items/1", { :controller => "bus_admin/budget_items", :action => "show", :id => "1" } ) 
    assert_generates( "/bus_admin/budget_items/1", { :controller => "bus_admin/budget_items", :action => "update", :id => "1" } )
    assert_generates( "/bus_admin/budget_items/1;edit", { :controller => "bus_admin/budget_items", :action => "edit", :id => "1" } ) 
    assert_generates( "/bus_admin/budget_items/1", { :controller => "bus_admin/budget_items", :action => "destroy", :id => "1" } )    
  end
  
  def test_routing_restful_path_generates_options
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "index" }, "/bus_admin/budget_items" )
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "create" }, { :path => "/bus_admin/budget_items", :method => :post } )  
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "new" }, "/bus_admin/budget_items/new" )
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "show", :id => "1" }, "/bus_admin/budget_items/1" )
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "update", :id => "1" }, { :path => "/bus_admin/budget_items/1", :method => :put } )  
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "edit", :id => "1" }, { :path => "/bus_admin/budget_items/1;edit", :method => :get } )    
    assert_recognizes( { :controller => "bus_admin/budget_items", :action => "destroy", :id => "1" }, { :path => "/bus_admin/budget_items/1", :method => :delete } )    
  end
  
#  def test_routing_restful_path_generates_options_and_options_generates_restful_path
#    assert_routing( "/bus_admin/budget_items", :controller => "bus_admin/budget_items", :action => "index" )
#    assert_routing( { :path => "/bus_admin/budget_items", :method => :post }, { :controller => "bus_admin/budget_items", :action => "create" } )
#  end  
  
end