require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::InvestmentsController do
  before do
    @user = mock_model(User)

    @project = mock_model(Project)
    @project.stub!(:name).and_return("Spec Project")
    @project.stub!(:fundable?).and_return(true)
    
    @investment = mock_model(Investment)
    Investment.stub!(:new).and_return(@investment)
    @investment.stub!(:project).and_return(@project)
  end
  
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  %w( index show edit update destroy ).each do |m|
    it "should not respond_to the #{m} method" do
      controller.should_not respond_to(m)
    end
  end
  
  %w( new create ).each do |m|
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
  
    it "should load the cf_unallocated_project if there's no investment.project" do
      @cf_project = mock_model(Project)
      Project.should_receive(:cf_unallocated_project).twice.and_return(@cf_project)
    
      @investment.should_receive(:project).any_number_of_times.and_return(nil)
      @investment.should_receive(:project=)
      get 'new'
    end
  end

  describe "create action" do
    before do 
      @investment.stub!(:user_ip_addr=).and_return("127.0.0.1")
      request.stub!(:remote_ip).and_return("127.0.0.1")
      controller.stub!(:request).and_return(request)
      controller.stub!(:request).and_return(request)
      @cart = Cart.new
      controller.stub!(:find_cart).and_return(@cart)
    end
    
    it "should add the current_user if logged_in?" do
      controller.should_receive(:logged_in?).and_return(true)
      controller.should_receive(:current_user).and_return(@user)
      @investment.should_receive(:user=).with(@user)
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
        controller.should_receive(:find_cart).and_return(@cart)
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
end
