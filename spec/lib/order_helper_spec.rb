require File.dirname(__FILE__) + '/../spec_helper'

require 'order_helper'
describe OrderHelper do
  before do
    klass = Class.new { include OrderHelper }
    @order_helper = klass.new
    @cart = Cart.new
    Cart.stub!(:new).and_return(@cart)
    @order = Order.new
    Order.stub!(:new).and_return(@order)
    @session = { :order_id => 1 }
    @order_helper.stub!(:session).and_return(@session)
    Order.stub!(:find).with(@session[:order_id]).and_return(@order)
  end
  
  describe "find_cart" do
    before do
      @session = { :cart => @cart }
    end
    it "should check to see if there's a current cart in the session" do
      @order_helper.should_receive(:session).at_least(:once).times.and_return(@session)
      @order_helper.find_cart
    end
  
    it "should create a new cart if there's no cart in the session" do
      @order_helper.should_receive(:session).at_least(:once).and_return({})
      Cart.should_receive(:new).and_return(@cart)
      @order_helper.find_cart
    end
  end
  
  describe "find_order" do
    it "should return an order if the session[:order_id] is a valid record" do
      Order.should_receive(:find).with(@session[:order_id]).and_return(@order)
      @order_helper.find_order
    end

    it "should return nil if the session[:order_id] is not a valid record" do
      Order.should_receive(:find).with(@session[:order_id]).and_return(nil)
      @order_helper.find_order
    end
  end
  
  describe "initialize_new_order" do
    before do
      @user = User.new(:first_name => 'mock', :last_name => 'user', :login => "user@example.com", :address => '36 Example St.', :city => "Guelph", :country => "Canada", :province => "ON", :postal_code => "H0H 0H0")
      @order_helper.stub!(:logged_in?).and_return(true)
      @order_helper.stub!(:current_user).and_return(@user)
      @order_helper.stub!(:params).and_return({:order => {}})
    end
    
    it "should load attributes from user into order" do
      count = %w(first_name last_name address city province postal_code country).size
      @order.should_receive(:attribute_present?).exactly(count).times.and_return(false)
      @order.should_receive(:write_attribute).exactly(count + 2).times # for user= and email=
      @user.should_receive(:read_attribute).exactly(count).times
      @order_helper.initialize_new_order
    end
  end
  
  describe "initialize_existing_order" do
    #before do
    #  @user = User.new(:first_name => 'mock', :last_name => 'user', :login => "user@example.com", :address => '36 Example St.', :city => "Guelph", :country => "Canada", :province => "ON", :postal_code => "H0H 0H0")
    #  @order_helper.stub!(:logged_in?).and_return(true)
    #  @order_helper.stub!(:current_user).and_return(@user)
    #  @order_helper.stub!(:params).and_return({:order => {}})
    #end

    #it "should load params[:order] into @order.attributes" do
    #  @order.should_receive(:attributes=).with(@order_helper.params[:order])
    #  @order_helper.initialize_existing_order
    #end
    #it "should set the total to the cart total" do
    #  @order.should_receive(:total=).with(@cart.total)
    #  @order_helper.initialize_existing_order
    #end
  end
end
