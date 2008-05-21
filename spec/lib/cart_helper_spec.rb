require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/cart_helper'
describe CartHelper do
  before do
    klass = Class.new { include CartHelper }
    @cart_helper = klass.new
    Cart.stub!(:new).and_return(@cart)
    @session = { :cart => @cart }
    @cart_helper.stub!(:session).and_return(@session)
  end

  it "should check to see if there's a current cart in the session" do
    @cart_helper.should_receive(:session).and_return(@session)
    @cart_helper.find_cart
  end
  
  it "should create a new cart if there's no cart in the session" do
    @cart_helper.should_receive(:session).and_return({})
    Cart.should_receive(:new).and_return(@cart)
    @cart_helper.find_cart
  end
end
