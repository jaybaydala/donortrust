require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::InvestmentsController do
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
  
  let(:unallocated_project) { mock_model(Project).as_null_object }
  let(:project) { mock_model(Project, :name => "foo", :fundable? => true).as_null_object }
  let(:investment) { mock_model(Investment, :project => project, :valid => true).as_null_object }
  let(:cart) { mock_model(Cart, :subscription? => false).as_null_object }
  let(:cart_line_item) { mock_model(CartLineItem, :item => investment) }
  let(:user) { mock_model(User).as_null_object }

  before do
    Project.stub(:find).and_return(project)
    Project.stub(:unallocated_project).and_return(unallocated_project)
    Cart.stub(:create).and_return(cart)
  end
  
  describe "new action" do
    before do
      Investment.stub(:new).and_return(investment)
    end
    it "should use the new template" do
      new_request
      response.should render_template("new")
    end
    it "should not require login" do
      controller.stub(:logged_in?).and_return(false)
      new_request
      response.should render_template("new")
    end
    it "should create a new investment" do
      Investment.should_receive(:new).and_return(investment)
      new_request
    end
    it "should redirect if the project is not fundable" do
      project.should_receive(:fundable?).and_return(false)
      new_request
      response.should be_redirect
    end
    it "should load params[:project_id] into the project" do
      investment.should_receive(:project=).with(project)
      investment.should_receive(:project).any_number_of_times.and_return(project)
      new_request
    end
    it "should load the unallocated_project if there's no investment.project" do
      investment.should_receive(:project).once.and_return(nil)
      investment.should_receive(:project).once.and_return(unallocated_project)
      new_request
      assigns[:project].should eql(unallocated_project)
    end
    it "should render the 'confirm_unallocated_gift' template if session[:gift_card_balance] && params[:unallocated_gift] == 1" do
      session[:gift_card_balance] = 1
      get 'new', :unallocated_gift => 1
      response.should render_template('confirm_unallocated_gift')
    end
    it "should render the 'new' template if session[:gift_card_balance] == 0 && params[:unallocated_gift] == 1" do
      session[:gift_card_balance] = 0
      get 'new', :unallocated_gift => 1
      response.should render_template('new')
    end
  end

  describe 'create action' do
    before do
      Investment.stub(:new).and_return(investment)
    end
    context "valid investment" do
      before do
        investment.stub(:valid?).and_return(true)
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
        cart.should_receive(:add_item).with(investment)
        create_request
      end
      it "should add the current_user if logged_in?" do
        controller.stub(:logged_in?).and_return(true)
        controller.stub(:current_user).and_return(user)
        investment.should_receive(:user_id=).with(user.id)
        create_request
      end
      it "should add the user_ip_addr" do
        investment.should_receive(:user_ip_addr=).with("0.0.0.0")
        create_request
      end
    end
    context "invalid investment" do
      before do
        investment.stub(:valid?).and_return(false)
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
      investment.stub(:valid?).and_return(true)
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
      assigns[:investment].should eql(investment)
    end
    it "should redirect if the item at id/index isn't the right type of object" do
      items = mock()
      items.should_receive(:find).and_return(mock(:cart_line_item, :item => Factory.build(:gift)))
      cart.should_receive(:items).and_return(items)
      edit_request
      response.should redirect_to(dt_cart_path)
    end
  end

  describe "update action" do
    let(:items) { mock(:cart_line_items, :find => cart_line_item) }
    before do
      investment.stub(:valid?).and_return(true)
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
      assigns[:investment].should eql(investment)
    end
    it "should update cart" do
      cart.should_receive(:update_item).with("1", investment)
      update_request
    end
    it "should redirect and not update cart if the item at id/index isn't the right type of object" do
      items = mock()
      items.should_receive(:find).and_return(mock(:cart_line_item, :item => Factory.build(:gift)))
      cart.should_receive(:items).and_return(items)
      cart.should_not_receive(:update_item)
      update_request
      response.should redirect_to(dt_cart_path)
    end
    it "should render the edit template if !valid?" do
      investment.stub(:valid?).and_return(false)
      update_request
      response.should render_template("edit")
    end
  end

  def new_request
    get "new", :project_id => project.id
  end

  def create_request(investment_params = {})
    post "create", :investment => { :amount => 10 }.merge(investment_params)
  end

  def edit_request
    get "edit", :id => 1
  end

  def update_request(investment_params = {})
    put "update", :id => 1, :investment => { :amount => 10 }.merge(investment_params)
  end
end
