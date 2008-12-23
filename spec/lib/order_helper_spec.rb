require File.dirname(__FILE__) + '/../spec_helper'

require 'order_helper'
require 'dt_application_controller'

class OrderHelperControllerSpec < DtApplicationController
 include OrderHelper
end

describe OrderHelperControllerSpec, "including OrderHelper", :type => :controller do
  before do
    OrderHelper.__send__(:public, :find_cart, :find_order, :initialize_new_order, :initialize_existing_order)
    @cart = Cart.new
    Cart.stub!(:new).and_return(@cart)
    @order = Order.create!
    Order.stub!(:new).and_return(@order)
    @session = { :order_id => 1 }
    controller.stub!(:session).and_return(@session)
    Order.stub!(:find).with(@session[:order_id]).and_return(@order)
  end

  describe "find_cart" do
    before do
      @session = { :cart => @cart }
    end
    it "should check to see if there's a current cart in the session" do
      controller.should_receive(:session).at_least(:once).times.and_return(@session)
      controller.find_cart
    end

    it "should create a new cart if there's no cart in the session" do
      controller.should_receive(:session).at_least(:once).and_return({})
      Cart.should_receive(:new).and_return(@cart)
      controller.find_cart
    end
  end

  describe "find_order" do
    it "should return an order if the session[:order_id] is a valid record" do
      Order.should_receive(:find).with(@session[:order_id]).and_return(@order)
      controller.find_order
    end

    it "should return nil if the session[:order_id] is not a valid record" do
      Order.should_receive(:find).with(@session[:order_id]).and_return(nil)
      controller.find_order
    end
  end

  describe "initialize_new_order" do
    before do
      @user = User.new(:first_name => 'mock', :last_name => 'user', :login => "user@example.com", :address => '36 Example St.', :city => "Guelph", :country => "Canada", :province => "ON", :postal_code => "H0H 0H0")
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(@user)
      controller.stub!(:params).and_return({:order => {}})
      @cart.stub!(:total).and_return(100)
      Order.stub!(:generate_order_number).and_return(rand(9999999999))
    end

    it "should load attributes from user into order" do
      count = %w(first_name last_name address city province postal_code country).size
      @order.should_receive(:attribute_present?).exactly(count).times.and_return(false)
      @order.should_receive(:write_attribute).exactly(count + 3).times # for user=, email=, total=, and credit_card_payment=
      @user.should_receive(:read_attribute).exactly(count).times
      controller.initialize_new_order
    end
    
    it "should set the account_balance attribute to the current_user.balance" do
      @user.stub!(:balance).and_return(100)
      @order.should_receive(:account_balance=).with(100).and_return(false)
      controller.initialize_new_order
    end
    it "should set the gift_card_balance attribute to the session[:gift_card_balance]" do
      controller.session[:gift_card_balance] = 50
      @order.should_receive(:gift_card_balance=).with(50).and_return(false)
      controller.initialize_new_order
    end

    it "should set the credit_card_payment to @order.total if !logged_in?" do
      controller.stub!(:logged_in?).and_return(false)
      @order.should_receive(:credit_card_payment=).with(@cart.total)
      controller.initialize_new_order
    end

    it "should set the credit_card_payment to @order.total if logged_in? and 0 balance" do
      @user.should_receive(:balance).and_return(0)
      @order.should_receive(:credit_card_payment=).with(@cart.total)
      controller.initialize_new_order
    end

    it "should not set the credit_card_payment to @order.total if logged_in? and balance > 0" do
      controller.should_receive(:logged_in?).at_least(:once).and_return(true)
      @user.should_receive(:balance).and_return(50)
      @order.should_not_receive(:credit_card_payment=)
      controller.initialize_new_order
    end
  end

  describe "initialize_existing_order" do
    before do
      @user = User.new(:first_name => 'mock', :last_name => 'user', :login => "user@example.com", :address => '36 Example St.', :city => "Guelph", :country => "Canada", :province => "ON", :postal_code => "H0H 0H0")
      @user.stub!(:balance).and_return(40.0)
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(@user)
      controller.stub!(:params).and_return({:order => {}})
      @cart.stub!(:total).and_return(100)
      @order = Order.create!(:amount => @cart.total, :email => "orderer@example.com")
    end

    it "should load params[:order] into @order.attributes" do
      @order.should_receive(:attributes=).with(controller.params[:order])
      controller.initialize_existing_order
    end

    it "should set the total to the cart total" do
      @order.should_receive(:total=).with(@cart.total)
      controller.initialize_existing_order
    end

    it "should set the user to the current_user if logged_in?" do
      @order.should_receive(:user=).with(@user)
      controller.initialize_existing_order
    end
  end
end