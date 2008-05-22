require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CheckoutsController do

  it "should extend DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end

  %w(new create show edit update ).each do |m|
    it "should respond to #{m}" do
      controller.should respond_to(m)
    end
  end
  %w(index destroy).each do |m|
    it "should not respond to #{m}" do
      controller.should_not respond_to(m)
    end
  end

  before do
    @investment = mock_model(Investment)
    @gift = mock_model(Gift)
    @cart = Cart.new
    @cart.stub!(:items).and_return([@investment, @gift])
    controller.stub!(:find_cart).and_return(@cart)
    @order = Order.new(:email => "user@example.com")
    controller.stub!(:find_order).and_return(@order)
  end
  
  describe "new action" do
    before do
      controller.stub!(:find_order).and_return(nil)
    end
    
    it "should render the new template" do
      do_request
      response.should render_template("new")
    end
    
    it "should find_cart" do
      controller.should_receive(:find_cart).and_return(@cart)
      do_request
    end
    
    it "should find_order" do
      controller.should_receive(:find_order).and_return(nil)
      do_request
    end
    
    it "should redirect to edit action if an existing order is found" do
      controller.should_receive(:find_order).and_return(@order)
      do_request
      response.should redirect_to(edit_dt_checkout_path)
    end
    
    it "should initialize_new_order" do
      controller.should_receive(:initialize_new_order).and_return(@order)
      do_request
    end

    it "should redirect to dt_cart_path if @cart.items are empty" do
      @cart.should_receive(:items).at_least(:once).and_return([])
      do_request
      flash[:notice].should_not be_blank
      response.should redirect_to(dt_cart_path)
    end
    
    def do_request
      get 'new'
    end
  end
  
  describe "create action" do
    before do
      controller.stub!(:find_order).and_return(nil)
      controller.stub!(:initialize_new_order).and_return(@order)
    end

    it "should redirect to edit_dt_checkout_path" do
      do_request
      response.should redirect_to(edit_dt_checkout_path(:step => "payment"))
    end

    it "should find_cart" do
      controller.should_receive(:find_cart).and_return(@cart)
      do_request
    end
    
    it "should find_order" do
      controller.should_receive(:find_order).and_return(nil)
      do_request
    end
    
    it "should redirect to edit action if an existing order is found" do
      controller.should_receive(:find_order).and_return(@order)
      do_request
      response.should redirect_to(edit_dt_checkout_path)
    end
    
    it "should initialize_new_order" do
      controller.should_receive(:initialize_new_order).and_return(@order)
      do_request
    end
    
    it "should save the order" do
      @order.should_receive(:save).and_return(true)
      do_request
    end

    it "should render the new template if the order can't save" do
      controller.stub!(:initialize_new_order).and_return(@order)
      @order.should_receive(:save).and_return(false)
      do_request
      response.should render_template("new")
    end
    
    def do_request(params = {})
      post 'create', :order => @order.attributes.merge(params)
    end
  end
  
  describe "edit method" do
    before do
      controller.stub!(:find_cart).and_return(@cart)
      controller.stub!(:find_order).and_return(@order)
    end
    
    it "should default to the edit template" do
      do_request
      response.should render_template("edit")
    end
    
    it "should find_cart" do
      controller.should_receive(:find_cart).and_return(@cart)
      do_request
    end

    it "should find_order" do
      controller.should_receive(:find_order).and_return(@order)
      do_request
    end
    
    it "should redirect to new_dt_checkout_path if there's no existing order" do
      controller.should_receive(:find_order).and_return(nil)
      do_request
      response.should redirect_to(new_dt_checkout_path)
    end
    
    %w(payment confirm).each do |s|
      it "should render the #{s} template when requested" do
        do_request(:step => s)
        response.should render_template(s)
      end  
    end
    
    it "should redirect to dt_cart_path if @cart.items are empty" do
      @cart.should_receive(:items).at_least(:once).and_return([])
      do_request
      flash[:notice].should_not be_blank
      response.should redirect_to(dt_cart_path)
    end

    def do_request(params = {})
      get "edit", params
    end
  end
  
  describe "update method" do
    before do
      controller.stub!(:find_cart).and_return(@cart)
      controller.stub!(:find_order).and_return(@order)
    end
    
    it "should redirect to the edit action" do
      do_request
      response.should redirect_to(edit_dt_checkout_path(:step => "payment"))
    end
    
    it "should find_cart" do
      controller.should_receive(:find_cart).and_return(@cart)
      do_request
    end

    it "should find_order" do
      controller.should_receive(:find_order).and_return(@order)
      do_request
    end
    
    it "should call @order.save" do
      @order.should_receive(:save).and_return(true)
      do_request
    end
    
    it "should call validate_billing on @order if !params[:step]" do
      @order.should_receive(:validate_billing)
      do_request
    end
    
    it "should redirect to new_dt_checkout_path if there's no existing order" do
      controller.should_receive(:find_order).and_return(nil)
      do_request
      response.should redirect_to(new_dt_checkout_path)
    end
    
    def do_request(params = {})
      put "update", params
    end
  end
end
