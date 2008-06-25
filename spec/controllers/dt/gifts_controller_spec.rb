require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::GiftsController do
  before do
    @user = mock_model(User)

    @project = mock_model(Project)
    @project.stub!(:name).and_return("Spec Project")
    @project.stub!(:fundable?).and_return(true)
    Project.stub!(:find).and_return(@project)
    
    @gift = mock_model(Gift)
    Gift.stub!(:new).and_return(@gift)
    @gift.stub!(:project).and_return(@project)
    @gift.stub!(:project_id?).and_return(true)
  end

  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  %w( destroy ).each do |m|
    it "should not respond_to the #{m} method" do
      controller.should_not respond_to(m)
    end
  end

  %w(index edit update new create show open unwrap preview).each do |m|
    it "should respond_to the #{m} method" do
      controller.should respond_to(m)
    end
  end
  
  it "should redirect to new on index" do
    get 'index'
    response.should redirect_to(new_dt_gift_path)
  end
  
  describe "new action" do
    before do
      @gift.stub!(:write_attribute).and_return(true)
      @gift.stub!(:attribute_present?).and_return(false)
      @gift.stub!(:name?).and_return(false)
      @gift.stub!(:email?).and_return(false)
      @gift.stub!(:email=).and_return(true)
      @gift.stub!(:send_email=).and_return(true)
      @user.stub!(:read_attribute).and_return(nil)
      @user.stub!(:full_name).and_return(nil)
      @user.stub!(:login).and_return("email@example.com")
      @user.stub!(:email).and_return(@user.login)
    end
    
    it "should store_location for login" do
      controller.should_receive(:store_location)
      get 'new'
    end
    
    it "should check the session for a gift (abandoned gift) and load it" do
      session_gift = mock_model(Gift)
      session[:gift_params] = session_gift
      get 'new'
      params[:gift].should == session_gift
    end
    
    it "should load all ecards" do
      ecards = [ECard.new]
      ECard.should_receive(:find).with(:all, :order => :id).and_return(ecards)
      get 'new'
      assigns(:ecards).should == ecards
    end

    it "should load the project into the gift if it's fundable?" do
      @project.should_receive(:fundable?).and_return(true)
      @gift.should_receive(:project=).with(@project)
      get 'new', :project_id => @project.id
    end
    
    it "should redirect if params[:project_id] and project_id is !fundable?" do
      @project.should_receive(:fundable?).and_return(false)
      get 'new', :project_id => @project.id
      response.should redirect_to(dt_project_path(@project))
    end
    
    describe "when logged_in?" do
      before do
        controller.stub!(:logged_in?).and_return(true)
        controller.stub!(:current_user).and_return(@user)
        @user.stub!(:in_country?).and_return(false)
      end
      
      it "should check if you're logged in" do
        controller.should_receive(:logged_in?).any_number_of_times.and_return(true)
        get 'new'
      end
      
      it "should load the user attributes into the gift" do
        %w(first_name last_name address city province postal_code country).each do |c|
          @user.should_receive(:read_attribute).twice.with(c)
          @gift.should_receive(:attribute_present?).with(c).and_return(false)
          @gift.should_receive(:write_attribute).with(c, @user.read_attribute(c)).and_return(true)
        end
        @gift.should_receive(:write_attribute).with("name", @user.full_name).and_return(true)
        get 'new'
      end
      
      it "should use the us_receipt_layout if current_user not in Canada" do
        @user.should_receive(:in_country?).and_return(false)
        get 'new'
        response.layout.should == 'layouts/us_receipt_layout'
      end
    end
    
    describe "when not logged_in?" do
      it "should render with the new template" do
        get 'new'
        response.should render_template('dt/gifts/new')
      end
    end
  end
  
  describe "create action" do
    before do 
      @gift.stub!(:user_ip_addr=).and_return("127.0.0.1")
      request.stub!(:remote_ip).and_return("127.0.0.1")
      controller.stub!(:request).and_return(request)
      @cart = Cart.new
      controller.stub!(:find_cart).and_return(@cart)
      now = Time.now
      Time.stub!(:now).and_return(now)
    end
    
    it "should load the gift_params" do
      controller.should_receive(:gift_params)
      post "create"
    end
    
    it "should load the remote_ip" do
      @gift.should_receive(:user_ip_addr=).with(request.remote_ip).and_return("127.0.0.1")
      post "create"
    end
    
    it "should check if the gift is valid" do
      @gift.should_receive(:valid?).twice.and_return(true)
      post "create"
    end
    
    it "should set the gift.send_at to 5 minutes in the future if send_gift is 'now'" do
      @gift.should_receive(:send_email=).with(true)
      @gift.should_receive(:send_at=).with(Time.now + 5.minutes)
      post "create", :gift => {:send_email => "now"}
    end
    
    describe "valid gift" do
      before do
        @gift.stub!(:valid?).and_return(true)
      end
      
      it "should find_cart" do
        controller.should_receive(:find_cart).and_return(@cart)
        post 'create'
      end
      
      it "should add_item to the cart" do
        @cart.should_receive(:add_item).with(@gift)
        post 'create'
      end
      
      it "should add a flash[:notice]" do
        post 'create'
        flash[:notice].should_not be_nil
      end
      
      it "should redirect to dt_cart_path" do
        post 'create'
        response.should redirect_to(dt_cart_path)
      end
    end
    
    describe "invalid gift" do
      before do
        @gift.stub!(:valid?).and_return(false)
        @gift.stub!(:project_id?).and_return(false)
      end
      
      it "should load the project" do
        @gift.should_receive(:project_id?).and_return(true)
        @gift.should_receive(:project).twice.and_return(@project)
        post 'create'
      end
      
      it "should load the ecards" do
        ecards = [ECard.new]
        ECard.should_receive(:find).with(:all, :order => :id).and_return(ecards)
        post 'create'
        assigns[:ecards].should == ecards
      end
      
      it "should render the new template" do
        post 'create'
        response.should render_template("dt/gifts/new")
      end
    end
  end

  describe "edit action" do
    before do
      @gift.stub!(:kind_of?).and_return(true)
      @cart = Cart.new
      @cart.stub!(:items).and_return([@gift])
      controller.stub!(:find_cart).and_return(@cart)
    end
    
    it "should render the edit template" do
      do_request
      response.should render_template("edit")
    end
    
    it "should load the cart" do
      controller.should_receive(:find_cart).and_return(@cart)
      do_request
    end
    
    it "should load the item from the cart" do
      @cart.should_receive(:items).twice.and_return([@gift])
      do_request
      assigns[:gift].should == @gift
    end
    
    it "should load the project" do
      @gift.should_receive(:project_id?).and_return(true)
      @gift.should_receive(:project).and_return(@project)
      do_request
      assigns[:project].should == @project
    end
    
    it "should redirect if the item at id/index isn't the right type of object" do
      @cart.should_receive(:items).and_return([Investment.new])
      do_request
      response.should redirect_to(dt_cart_path)
    end
    
    def do_request
      get 'edit', :id => 0
    end
  end

  describe "update action" do
    before do
      @gift.stub!(:kind_of?).and_return(true)
      @gift.stub!(:attributes=).and_return(true)
      @gift.stub!(:user_ip_addr=).and_return(true)
      @gift.stub!(:valid?).and_return(true)
      @cart = Cart.new
      @cart.stub!(:items).and_return([@gift])
      controller.stub!(:find_cart).and_return(@cart)
    end
    
    it "should redirect to dt_cart_path" do
      do_request
      response.should redirect_to(dt_cart_path)
    end
    
    it "should load the cart" do
      controller.should_receive(:find_cart).and_return(@cart)
      do_request
    end
    
    it "should load the item from the cart" do
      @cart.should_receive(:items).twice.and_return([@gift])
      do_request
      assigns[:gift].should == @gift
    end
    
    it "should update cart" do
      @cart.should_receive(:update_item).with("0", @gift)
      do_request
    end

    it "should add a \"successful\" notice" do
      do_request
      flash[:notice].should_not be_blank
    end
    
    it "should redirect and not update cart if the item at id/index isn't the right type of object" do
      @cart.should_receive(:items).and_return([Investment.new])
      @cart.should_not_receive(:update_item)
      do_request
      response.should redirect_to(dt_cart_path)
    end
    
    it "should render the edit template if !valid?" do
      @gift.should_receive(:valid?).and_return(false)
      do_request
      response.should render_template("edit")
    end

    it "should load @project if !valid?" do
      @gift.should_receive(:valid?).and_return(false)
      @gift.should_receive(:project_id?).and_return(true)
      @gift.should_receive(:project).and_return(@project)
      do_request
      assigns[:project].should == @project
    end
    
    def do_request
      put 'update', :id => 0, :gift => {:amount => 50}
    end
  end
end