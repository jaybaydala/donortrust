require File.dirname(__FILE__) + '/../spec_helper'

require 'order_helper'
require 'dt_application_controller'

class OrderHelperControllerSpec < DtApplicationController
 include OrderHelper
end

describe OrderHelperControllerSpec, :type => :controller do
  let(:cart) { Cart.create! }
  let(:order) { Factory(:order, :email => "user@example.com", :cart => cart, :credit_card_payment => 0) }
  let(:session) { { :order_id => order.id } }

  before do
    Cart.stub(:create).and_return(cart)
    OrderHelper.__send__(:public, :find_cart, :find_order, :initialize_new_order, :initialize_existing_order)
    controller.stub!(:session).and_return(session)
    # Order.stub!(:find).with(session[:order_id]).and_return(order)
  end

  describe "find_cart" do
    let(:session) { { :cart_id => cart.id} }
    it "should check to see if there's a current cart in the session" do
      controller.should_receive(:session).at_least(:once).times.and_return(session)
      controller.send(:find_cart)
    end

    it "should create a new cart if there's no cart in the session" do
      controller.should_receive(:session).at_least(:once).and_return({})
      Cart.should_receive(:create).and_return(cart)
      controller.send(:find_cart)
    end
  end

  describe "find_order" do
    before do
      Order.stub(:exists?).and_return(true)
    end

    it "should return an order if the session[:order_id] is a valid record" do
      controller.send(:find_order).should eql(order)
    end

    it "should return nil if the session[:order_id] is not a valid record" do
      Order.should_receive(:exists?).with(session[:order_id]).and_return(false)
      controller.send(:find_order)
    end
  end

  describe "initialize_new_order" do
    let(:user) { Factory(:user, :country => "Canada") }
    before do
      user.stub(:balance).and_return(0)
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(user)
      controller.stub!(:params).and_return({:order => {}})
      cart.stub!(:total).and_return(100)
      Order.stub!(:new).and_return(order)
      Order.stub!(:generate_order_number).and_return(rand(9999999999))
    end

    it "should set the account_balance attribute to the current_user.balance" do
      user.stub!(:balance).and_return(100)
      order.should_receive(:account_balance=).with(100).and_return(false)
      controller.send(:initialize_new_order)
    end
    it "should set the gift_card_balance attribute to the session[:gift_card_balance]" do
      gift = Factory(:gift, :amount => 50)
      controller.session[:gift_card_id] = gift.id
      order.should_receive(:gift_card_balance=).with(50).and_return(false)
      controller.send(:initialize_new_order)
    end

    it "should set the credit_card_payment to order.total if !logged_in?" do
      controller.stub!(:logged_in?).and_return(false)
      order.should_receive(:credit_card_payment=).with(cart.total)
      controller.send(:initialize_new_order)
    end

    it "should set the credit_card_payment to order.total if logged_in? and 0 balance" do
      user.should_receive(:balance).and_return(0)
      order.should_receive(:credit_card_payment=).with(cart.total)
      controller.send(:initialize_new_order)
    end

    it "should not set the credit_card_payment to order.total if logged_in? and balance > 0" do
      controller.should_receive(:logged_in?).at_least(:once).and_return(true)
      user.should_receive(:balance).and_return(50)
      order.should_not_receive(:credit_card_payment=)
      controller.send(:initialize_new_order)
    end
  end

  describe "initialize_existing_order" do
    let(:user) { Factory(:user, :first_name => 'mock', :last_name => 'user', :login => "user@example.com", :address => '36 Example St.', :city => "Guelph", :country => "Canada", :province => "ON", :postal_code => "H0H 0H0") }

    before do
      user.stub!(:balance).and_return(40.0)
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(user)
      controller.stub!(:params).and_return({:order => {}})
      cart.stub!(:total).and_return(100)
      Order.stub(:exists?).and_return(true)
      Order.stub(:find).and_return(order)
    end

    it "should load params[:order] into order.attributes" do
      order.should_receive(:attributes=).with(controller.params[:order])
      controller.send(:initialize_existing_order)
    end

    it "should set the total to the cart total" do
      order.should_receive(:total=).with(cart.total)
      controller.send(:initialize_existing_order)
    end

    it "should set the user to the current_user if logged_in?" do
      order.should_receive(:user=).with(user).at_least(:once)
      controller.send(:initialize_existing_order)
    end
  end
end