require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::InvestmentsController do
  before do
    @user = mock_model(User)

    @project = mock_model(Project)
    @project.stub!(:name).and_return("Spec Project")
    @project.stub!(:fundable?).and_return(true)
    
    @investment = Investment.new
    Investment.stub!(:new).and_return(@investment)
    @investment.stub!(:project).and_return(@project)
    @investment.stub!(:project_id?).and_return(true)
  end
  
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
  
  describe "new action" do
    it "should not redirect if !logged_in?" do
      get 'new'
      response.should be_success
    end
  
    it "should redirect if the project is not fundable" do
      @project.should_receive(:fundable?).and_return(false)
      get 'new'
      response.should be_redirect
    end
  
    it "should load params[:project_id] into the project" do
      @investment.should_receive(:project_id=).with(@project)
      @investment.should_receive(:project).any_number_of_times.and_return(@project)
      get 'new', :project_id => @project
    end
  
    it "should load the unallocated_project if there's no investment.project" do
      @cf_project = mock_model(Project)
      Project.should_receive(:unallocated_project).twice.and_return(@cf_project)
    
      @investment.should_receive(:project).any_number_of_times.and_return(nil)
      @investment.should_receive(:project=)
      get 'new'
    end
    
    it "should render the 'confirm_unallocated_gift' template if session[:gift_card_balance] && params[:unallocated_gift] == 1" do
      session[:gift_card_balance] = 1
      get 'new', :unallocated_gift => 1
      response.should render_template(:confirm_unallocated_gift)
    end
    it "should render the 'new' template if session[:gift_card_balance] == 0 && params[:unallocated_gift] == 1" do
      session[:gift_card_balance] = 0
      get 'new', :unallocated_gift => 1
      response.should render_template(:new)
    end
  end

  describe "create action" do
    before do 
      @investment.stub!(:user_ip_addr=).and_return("127.0.0.1")
      request.stub!(:remote_ip).and_return("127.0.0.1")
      controller.stub!(:request).and_return(request)
      @cart = Cart.new
      Cart.stub!(:new).and_return(@cart)
    end
    
    it "should add the current_user if logged_in?" do
      controller.should_receive(:logged_in?).and_return(true)
      controller.should_receive(:current_user).and_return(@user)
      @investment.should_receive(:user_id=).with(@user.id)
      post 'create'
    end
    
    it "should add the user_ip_addr" do
      @investment.should_receive(:user_ip_addr=).with("127.0.0.1")
      post 'create'
    end
    
    it "should check the validity of the investment" do
      @investment.should_receive(:valid?).any_number_of_times.and_return(true)
      post 'create'
    end
    
    describe "failing create" do
      before do
        @investment.stub!(:valid?).and_return(false)
      end
      
      it "should render the new template" do
        post 'create'
        response.should render_template(:new)
      end
    end
    
    describe "successful create" do
      before do
        @investment.stub!(:valid?).and_return(true)
      end
      
      it "should load the the cart" do
        Cart.should_receive(:new).and_return(@cart)
        post 'create'
      end
      
      it "should add_item to the cart" do
        @cart.should_receive(:add_item)
        post 'create'
      end
      
      it "should add a flash[:notice]" do
        post 'create'
        flash[:notice].should_not be_blank
      end
      
      it "should redirect to show the cart" do
        post 'create'
        response.should redirect_to(dt_cart_path)
      end
    end
  end
  
  describe "edit action" do
    before do
      @investment.stub!(:kind_of?).and_return(true)
      @cart = Cart.new
      @cart.stub!(:items).and_return([@investment])
      Cart.stub!(:new).and_return(@cart)
    end
    
    it "should render the edit template" do
      do_request
      response.should render_template("edit")
    end
    
    it "should load the cart" do
      Cart.should_receive(:new).and_return(@cart)
      do_request
    end
    
    it "should load the item from the cart" do
      @cart.should_receive(:items).twice.and_return([@investment])
      do_request
      assigns[:investment].should == @investment
    end
    
    it "should load the project" do
      @investment.should_receive(:project_id?).and_return(true)
      @investment.should_receive(:project).and_return(@project)
      do_request
      assigns[:project].should == @project
    end
    
    it "should redirect if the item at id/index isn't the right type of object" do
      @cart.should_receive(:items).and_return([@gift])
      do_request
      response.should redirect_to(dt_cart_path)
    end
    
    def do_request
      get 'edit', :id => 0
    end
  end

  describe "update action" do
    before do
      @investment.stub!(:kind_of?).and_return(true)
      @investment.stub!(:attributes=).and_return(true)
      @investment.stub!(:user_ip_addr=).and_return(true)
      @investment.stub!(:valid?).and_return(true)
      @cart = Cart.new
      @cart.stub!(:items).and_return([@investment])
      Cart.stub!(:new).and_return(@cart)
    end
    
    it "should redirect to dt_cart_path" do
      do_request
      response.should redirect_to(dt_cart_path)
    end
    
    it "should load the cart" do
      Cart.should_receive(:new).and_return(@cart)
      do_request
    end
    
    it "should load the item from the cart" do
      @cart.should_receive(:items).twice.and_return([@investment])
      do_request
      assigns[:investment].should == @investment
    end
    
    it "should update cart" do
      @cart.should_receive(:update_item).with("0", @investment)
      do_request
    end

    it "should add a \"successful\" notice" do
      do_request
      flash[:notice].should_not be_blank
    end
    
    it "should redirect and not update cart if the item at id/index isn't the right type of object" do
      @cart.should_receive(:items).and_return([@gift])
      @cart.should_not_receive(:update_item)
      do_request
      response.should redirect_to(dt_cart_path)
    end
    
    it "should render the edit template if !valid?" do
      @investment.should_receive(:valid?).and_return(false)
      do_request
      response.should render_template("edit")
    end

    it "should load @project if !valid?" do
      @investment.should_receive(:valid?).and_return(false)
      @investment.should_receive(:project_id?).and_return(true)
      @investment.should_receive(:project).and_return(@project)
      do_request
      assigns[:project].should == @project
    end
    
    def do_request
      put 'update', :id => 0, :investment => {:amount => 50}
    end
  end
end
