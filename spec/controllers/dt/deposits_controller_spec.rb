require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::DepositsController do
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  %w( index show destroy ).each do |m|
    it "should not respond_to the #{m} method" do
      controller.should_not respond_to(m)
    end
  end
  %w( new create edit update ).each do |m|
    it "should respond_to the #{m} method" do
      controller.should respond_to(m)
    end
  end
  
  let(:deposit) { mock_model(Deposit).as_null_object }
  let(:user) { mock_model(User).as_null_object }
  let(:cart) { mock_model(Cart).as_null_object }
  let(:cart_line_item) { mock_model(CartLineItem, :item => deposit) }

  before do
    user.stub(:in_country?).and_return(true)
    controller.stub(:logged_in?).and_return(true)
    controller.stub(:current_user).and_return(user)
    Cart.stub(:create).and_return(cart)
  end
  
  describe "new action" do
    it "should use the new template" do
      new_request
      response.should render_template("new")
    end
    it "should require login" do
      controller.should_receive(:logged_in?).and_return(false)
      new_request
      response.should redirect_to(login_path)
    end
    it "should load the session[:deposit_params] into params[:deposit]" do
      controller.should_receive(:session).any_number_of_times.and_return({:deposit_params => {:amount => 100}})
      new_request
      params[:deposit][:amount].should == 100
    end
    it "should create a new Deposit" do
      Deposit.should_receive(:new).and_return(deposit)
      new_request
    end
    # it "should use the us_receipt_layout if current_user isn't in canada" do
    #   user.should_receive(:in_country?).with('canada').and_return(false)
    #   new_request
    #   response.layout.should == 'layouts/us_receipt_layout'
    # end
  end

  describe 'create action' do
    before do
      Deposit.stub(:new).and_return(deposit)
    end
    it "should require login" do
      controller.should_receive(:logged_in?).and_return(false)
      create_request
      response.should redirect_to(login_path)
    end
    context "valid deposit" do
      before do
        deposit.stub(:valid?).and_return(true)
      end
      it "should redirect to dt_cart_path" do
        create_request
        response.should redirect_to(dt_cart_path)
      end
      it "should find_cart" do
        Cart.should_receive(:create).and_return(cart)
        create_request
      end
      it "should add_item to cart" do
        cart.should_receive(:add_item).with(deposit)
        create_request
      end
    end
    context "invalid deposit" do
      before do
        deposit.stub(:valid?).and_return(false)
      end
      it "should render the new template" do
        create_request
        response.should render_template("new")
      end
    end
  end

  describe "edit action" do
    let(:items) { mock(:cart_line_items, :find => cart_line_item) }
    before do
      cart.stub(:items).and_return(items)
    end
    it "should render the edit template" do
      edit_request
      response.should render_template("edit")
    end
    it "should load the cart" do
      Cart.should_receive(:create).and_return(cart)
      edit_request
    end
    it "should load the item from the cart" do
      cart.should_receive(:items).twice.and_return(items)
      edit_request
      assigns[:deposit].should eql(deposit)
    end
    it "should redirect if the item at id/index isn't the right type of object" do
      items = mock()
      items.should_receive(:find).and_return(mock(:cart_line_item, :item => Factory.build(:investment)))
      cart.should_receive(:items).and_return(items)
      edit_request
      response.should redirect_to(dt_cart_path)
    end
  end

  describe "update action" do
    let(:items) { mock(:cart_line_items, :find => cart_line_item) }
    before do
      cart.stub(:items).and_return(items)
    end
    it "should redirect to dt_cart_path" do
      update_request
      response.should redirect_to(dt_cart_path)
    end
    it "should load the cart" do
      Cart.should_receive(:create).and_return(cart)
      update_request
    end
    it "should load the item from the cart" do
      cart.should_receive(:items).twice.and_return(items)
      update_request
      assigns[:deposit].should eql(deposit)
    end
    it "should update cart" do
      cart.should_receive(:update_item).with("1", deposit)
      update_request
    end
    it "should redirect and not update cart if the item at id/index isn't the right type of object" do
      items = mock()
      items.should_receive(:find).and_return(mock(:cart_line_item, :item => Factory.build(:investment)))
      cart.should_receive(:items).and_return(items)
      cart.should_not_receive(:update_item)
      update_request
      response.should redirect_to(dt_cart_path)
    end
    it "should render the edit template if !valid?" do
      deposit.stub(:valid?).and_return(false)
      update_request
      response.should render_template("edit")
    end
  end

  def new_request
    get "new", :account_id => user.id
  end

  def create_request(deposit_params = {})
    post "create", :account_id => user.id, :deposit => { :amount => 10, :user_id => user.id }.merge(deposit_params)
  end

  def edit_request
    get "edit", :account_id => user.id, :id => 1
  end

  def update_request(deposit_params = {})
    put "update", :account_id => user.id, :id => 1, :deposit => { :amount => 10, :user_id => user.id }.merge(deposit_params)
  end
end
