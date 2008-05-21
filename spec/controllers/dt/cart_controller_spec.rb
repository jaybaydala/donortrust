require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CartController do
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  it "should implement the show method" do
    controller.should respond_to(:show)
  end
  
  before do
    @cart = Cart.new
    controller.stub!(:find_cart).and_return(@cart)
  end
  
  it "should find_cart" do
    controller.should_receive(:find_cart).and_return(@cart)
    get "show"
  end
end
