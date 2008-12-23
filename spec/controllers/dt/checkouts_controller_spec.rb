require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CheckoutsController do

  it "should extend DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end

  %w(new create show edit update destroy ).each do |m|
    it "should respond to #{m}" do
      controller.should respond_to(m)
    end
  end
  %w(index).each do |m|
    it "should not respond to #{m}" do
      controller.should_not respond_to(m)
    end
  end

  before do
    @investment = Investment.generate!
    @gift = Gift.generate!
    @cart = Cart.new
    @user = User.generate!
    @cart.add_item @gift
    @cart.add_item @investment
    controller.stub!(:find_cart).and_return(@cart)
    @order = Order.create!(:email => "user@example.com")
    @order.total = @cart.total
    controller.stub!(:find_order).and_return(@order)
  end
  
  it "should define CHECKOUT_STEPS as %w(support billing payment confirm)" do
    controller.class::CHECKOUT_STEPS.should == %w( support payment billing confirm )
  end
  
  # %w(new create edit update destroy).each do |action|
  #   it "#{action} action should redirect to dt_cart_path if @cart is empty" do
  #     @cart.should_receive(:empty?).at_least(:once).and_return(true)
  #     if %w(new edit).include?(action)
  #       get action
  #     elsif action == "create"
  #       post action
  #     elsif action == "update"
  #       put action
  #     elsif action == 'destroy'
  #       delete action 
  #     end
  #     
  #     flash[:notice].should_not be_blank
  #     response.should redirect_to(dt_cart_path)
  #   end
  # end
  # 
  # describe "current_step" do
  #   %w(support billing payment confirm).each do |step|
  #     it "should be #{step} when params[:step] is \"#{step}\"" do
  #       get "edit", :step => step
  #       controller.send!(:current_step).should == step
  #     end
  #   end
  #   it "should be nil when no params[:step]" do
  #     get "edit"
  #     controller.send!(:current_step).should be_nil
  #   end
  # end
  # 
  # describe "next_step" do
  #   %w(support billing payment confirm).each do |step|
  #     it "should be the following step when params[:step] is \"#{step}\"" do
  #       get "edit", :step => step
  #       controller.send!(:next_step).should == controller.class::CHECKOUT_STEPS[controller.class::CHECKOUT_STEPS.index(step)+1]
  #     end
  #   end
  #   it "should be support when no params[:step]" do
  #     get "edit"
  #     controller.send!(:next_step).should == "support"
  #   end
  # end
  # 
  # describe "show action" do
  #   before do
  #     @session = {:order_number => [12345]}
  #     @controller.stub!(:session).and_return(@session)
  #     Order.stub!(:find_by_order_number).and_return(@order)
  #     @order.stub!(:complete?).and_return(true)
  #   end
  #   
  #   it "should render the show template" do
  #     do_request
  #     response.should render_template("show")
  #   end
  #   
  #   it "should find the order by order_number" do
  #     Order.should_receive(:find_by_order_number).and_return(@order)
  #     do_request
  #   end
  #   
  #   it "show action should not redirect to dt_cart_path if @cart is empty" do
  #     @cart.should_receive(:empty?).never
  #     do_request
  #     flash[:notice].should be_blank
  #     response.should_not redirect_to(dt_cart_path)
  #   end
  #   
  #   it "should redirect to dt_cart_path if no order is found" do
  #     Order.should_receive(:find_by_order_number).and_return(nil)
  #     do_request
  #     response.should redirect_to(dt_cart_path)
  #   end
  # 
  #   it "should redirect to edit_dt_checkout_path if order is incomplete" do
  #     @order.should_receive(:complete?).and_return(false)
  #     do_request
  #     response.should redirect_to(edit_dt_checkout_path)
  #   end
  #   
  #   it "should redirect if session[:order_number] doesn't include the order_number" do
  #     @session = {:order_number => [6789]}
  #     do_request
  #     response.should redirect_to(dt_cart_path)
  #   end
  #   
  #   def do_request(params = {})
  #     get "show", {:order_number => @session[:order_number].to_s}.merge(params)
  #   end
  # end
  # 
  # describe "new action" do
  #   before do
  #     controller.stub!(:find_order).and_return(nil)
  #   end
  #  
  #   it "should render the new template" do
  #     do_request
  #     response.should render_template("new")
  #   end
  #   
  #   it "should find_cart" do
  #     controller.should_receive(:find_cart).once.and_return(@cart)
  #     do_request
  #   end
  #   
  #   it "should find_order" do
  #     controller.should_receive(:find_order).once.and_return(nil)
  #     do_request
  #   end
  # 
  #   it "should redirect to edit action if an existing order is found" do
  #     controller.should_receive(:find_order).and_return(@order)
  #     do_request
  #     response.should redirect_to(edit_dt_checkout_path)
  #   end
  #   
  #   it "should initialize_new_order" do
  #     controller.should_receive(:initialize_new_order).and_return(@order)
  #     do_request
  #   end
  # 
  #   it "should redirect to dt_cart_path if @cart.items are empty" do
  #     @cart.should_receive(:empty?).once.and_return(true)
  #     do_request
  #     flash[:notice].should_not be_blank
  #     response.should redirect_to(dt_cart_path)
  #   end
  #   
  #   def do_request
  #     get 'new'
  #   end
  # end
  # 
  describe "create action" do
    before do
      Order.stub!(:new).and_return(@order)
      controller.stub!(:find_order).and_return(nil)
      controller.stub!(:validate_order).and_return(true)
    end
    
    it "should redirect to \"support\" if no current_step" do
      do_request(:step => nil)
      response.should redirect_to(edit_dt_checkout_path(:step => "support"))
    end
    
    it "should find_cart" do
      controller.should_receive(:find_cart).once.and_return(@cart)
      do_request
    end
    
    it "should find_order" do
      controller.should_receive(:find_order).at_least(:once).and_return(nil)
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
    
    it "should redirect to edit action if an existing order is found" do
      controller.should_receive(:find_order).and_return(@order)
      do_request
      response.should redirect_to(edit_dt_checkout_path)
    end
  
    it "should validate the order" do
      controller.should_receive(:validate_order).and_return(true)
      do_request
    end
  
    it "should save the order" do
      @order.should_receive(:save).and_return(true)
      do_request
    end
  
    it "should note save the order if it's not valid" do
      controller.should_receive(:validate_order).and_return(false)
      @order.should_receive(:save).never
      do_request
    end
    
    it "should put the order_id in the session" do
      do_request
      session[:order_id].should == @order.id
    end
  
    it "should not put the order_id in the session for an invalid order" do
      controller.should_receive(:validate_order).and_return(false)
      do_request
      session[:order_id].should == nil
    end
  
    it "should render the new template if the order can't save" do
      @order.should_receive(:save).and_return(false)
      do_request
      response.should render_template("new")
    end
    
    describe "with a gift card" do
      describe "that has a balance larger than the total" do
        before do
          @order.total = @cart.total
          @gift_card = Gift.generate!(:amount => @order.total + 1, :balance => @order.total + 1)
          controller.session[:gift_card_balance] = @gift_card.balance
        end
        it "should set gift_card_payment to order.total when the user has no balance" do
          @gift_card.update_attributes(:amount => @order.total + 1, :balance => @order.total + 1)
          @user.stub!(:balance).and_return(0)
          do_request
          @order.gift_card_payment.should == @order.total
        end
        it "should set credit_card_payment to 0 when the user has no balance and has a gift card larger than the total" do
          new_balance = @order.total + 1
          @gift_card.update_attributes(:amount => new_balance, :balance => new_balance)
          @user.stub!(:balance).and_return(0)
          do_request
          @order.credit_card_payment.should == 0
        end
      end
    end
    describe "with a logged in user" do
      before do
        @user = User.generate!
        @controller.stub!(:logged_in?).and_return(true)
        @controller.stub!(:current_user).and_return(@user)
        @user.stub!(:balance).and_return(10)
      end
      it "should check the user's balance" do
        @user.should_receive(:balance)
        do_request
      end
      it "should set credit_card_payment to order.total when the user has no balance" do
        @user.stub!(:balance).and_return(0)
        do_request
        @order.credit_card_payment.should == @order.total
      end
      describe "with a gift card" do
        before do
          @gift_card = Gift.generate!(:amount => @order.total - 1)
          controller.session[:gift_card_balance] = @gift_card.balance
          controller.session[:gift_card_id] = @gift_card.id
        end
        it "should set gift_card_payment to gift_card_balance when the user has no balance and has a gift card" do
          @user.stub!(:balance).and_return(0)
          do_request
          @order.gift_card_payment.should == @gift_card.balance
        end
        it "should set credit_card_payment to order.total-gift_card_balance when the user has no balance and has a gift card" do
          @user.stub!(:balance).and_return(0)
          do_request
          @order.credit_card_payment.should == 1
        end
      end
    end

    
    def do_request(params = {})
      params = {:step => "support"}.merge(@order.attributes.merge(params))
      post 'create', :order => params
    end
  end
  
  # describe "edit action" do
  #   before do
  #     controller.stub!(:find_cart).and_return(@cart)
  #     controller.stub!(:find_order).and_return(@order)
  #     @step = nil
  #   end
  #   
  #   it "should redirect to the step=support" do
  #     do_request
  #     response.should redirect_to(edit_dt_checkout_path(:step => "support"))
  #   end
  #   
  #   it "should find_cart" do
  #     controller.should_receive(:find_cart).and_return(@cart)
  #     do_request
  #   end
  # 
  #   it "should find_order" do
  #     controller.should_receive(:find_order).once.and_return(@order)
  #     do_request
  #   end
  #   
  #   it "should redirect to new_dt_checkout_path if there's no existing order" do
  #     controller.should_receive(:find_order).once.and_return(nil)
  #     do_request
  #     response.should redirect_to(new_dt_checkout_path)
  #   end
  #   
  #   Dt::CheckoutsController::CHECKOUT_STEPS.each do |step|
  #     it "should render the #{step} template when requested" do
  #       do_request(:step => step)
  #       response.should render_template(step)
  #     end
  #   end
  # 
  #   describe "on the billing step" do
  #     before do
  #       @step = "billing"
  #     end
  #     it "should receive before_billing" do
  #       controller.should_receive(:before_billing)
  #       do_request
  #     end
  #   end
  # 
  #   describe "on the payment step" do
  #     before do
  #       @step = "payment"
  #       @order.stub!(:card_number=).and_return(true)
  #       @order.stub!(:cvv=).and_return(true)
  #     end
  #     
  #     it "should set the card_number field to nil so they user has to re-enter it" do
  #       @order.should_receive(:card_number=).with(nil)
  #       do_request
  #     end
  #     it "should set the cvv field to nil so the user has to re-enter it" do
  #       @order.should_receive(:cvv=).with(nil)
  #       do_request
  #     end
  #     it "should set the expiry_month field to nil so the user has to re-enter it" do
  #       @order.should_receive(:expiry_month=).with(nil)
  #       do_request
  #     end
  #     it "should set the expiry_year field to nil so the user has to re-enter it" do
  #       @order.should_receive(:expiry_year=).with(nil)
  #       do_request
  #     end
  #     it "should set the cardholder_name field to nil so the user has to re-enter it" do
  #       @order.should_receive(:cardholder_name=).with(nil)
  #       do_request
  #     end
  #   end
  # 
  #   def do_request(params = {})
  #     params = {:step => @step}.merge(params)
  #     get "edit", params
  #   end
  # end
  
  describe "update action" do
    before do
      @order = Order.create!(:email => "user@example.com")
      
      controller.stub!(:find_cart).and_return(@cart)
      controller.stub!(:find_order).and_return(@order)
      controller.stub!(:validate_order).and_return(true)
      @step = nil
    end
    it "should redirect to the support step" do
      do_request
      response.should redirect_to(edit_dt_checkout_path(:step => "support"))
    end
    
    # ["support", "billing", "payment", "confirm"].each do |step|
    #   describe "for all steps (#{step} step)" do
    #     before do
    #       @step = step
    #       if step == "confirm"
    #         @order.stub!(:run_transaction).and_return(true)
    #         controller.stub!(:validate_order).and_return(true)
    #       end
    #     end
    #     it "should validate_order" do
    #       controller.should_receive(:validate_order).and_return(true)
    #       do_request
    #     end
    #     it "should call do_action" do
    #       controller.should_receive(:do_action).and_return(true)
    #       do_request
    #     end
    #     it "should set current_step to the current step (duh)" do
    #       do_request
    #       controller.__send__(:current_step).should == @step
    #     end
    #     it "should save the order if it's valid" do
    #       controller.should_receive(:validate_order).and_return(true)
    #       # do_action can invalidate the order - we're exploring that elsewhere in this describe block
    #       controller.stub!(:do_action).and_return(true)
    #       @order.should_receive(:save).and_return(true)
    #       do_request
    #     end
    #     it "should not save the order if it's not valid" do
    #       controller.should_receive(:validate_order).and_return(false)
    #       @order.should_receive(:save).never
    #       do_request
    #     end
    #     it "should render the #{step} template if it's not valid" do
    #       controller.should_receive(:validate_order).and_return(false)
    #       do_request
    #       response.should render_template(step)
    #     end
    #     it "should render the next step's template if the order is valid and there's a next step available" do
    #       controller.stub!(:validate_order).and_return(true)
    #       # do_action can invalidate the order - we're exploring that elsewhere in this describe block
    #       controller.stub!(:do_action).and_return(true)
    #       @order.should_receive(:complete?).and_return(true) if step == "confirm" # we're on the last step
    #       do_request
    #       next_step = controller.__send__(:next_step)
    #       if next_step
    #         response.should render_template(next_step) if next_step
    #       else # we're on the last step
    #         response.should redirect_to(dt_checkout_path(:order_number => @order.order_number))
    #       end
    #     end
    #   end
    # end
    # describe "on the support step" do
    #   before do
    #     @step = "support"
    #   end
    #   
    #   it "next_step should be 'payment'" do
    #     do_request
    #     controller.send!(:next_step).should == "payment"
    #   end
    #   
    #   it "should call do_support" do
    #     controller.should_receive(:do_support)
    #     do_request
    #   end
    #   
    #   it "should render the payment step if order is valid" do
    #     controller.stub!(:validate_order).and_return(true)
    #     controller.stub!(:do_action).and_return(true)
    #     do_request
    #     response.should render_template("payment")
    #   end
    #   
    #   describe "in the do_support method" do
    #     before do
    #       # set up projects
    #       @admin_project = Project.admin_project || Project.generate!(:slug => 'admin')
    #       @unallocated_project = Project.unallocated_project || Project.generate!(:slug => 'unallocated')
    #       # set up investment(s)/gift(s)
    #       @admin_investment = Investment.spawn(:amount => 10, :checkout_investment => true)
    #       @admin_investment.project = @admin_project
    #       Investment.stub!(:new).and_return(@admin_investment)
    #       @gift.project = Project.generate!
    #       @investment.project = Project.generate!
    #     end
    #     
    #     it "should not call Project.admin_project unless params[:fund_cf]" do
    #       Project.should_receive(:admin_project).never
    #       do_request(:fund_cf => nil)
    #     end
    # 
    #     it "should call Project.admin_project if params[:fund_cf] == 'dollars'" do
    #       Project.stub!(:admin_project).and_return(@admin_project)
    #       do_request(:fund_cf => "dollars")
    #     end
    # 
    #     it "should call Project.admin_project if params[:fund_cf] == 'percent'" do
    #       Project.stub!(:admin_project).and_return(@admin_project)
    #       do_request(:fund_cf => "percent")
    #     end
    # 
    #     it "should call Project.admin_project if params[:fund_cf] == 'no'" do
    #       Project.stub!(:admin_project).and_return(@admin_project)
    #       do_request(:fund_cf => "no")
    #     end
    #     
    #     it "should add a base error to the order if the user doesn't choose a fund_cf option" do
    #       @order.errors.should_receive(:add_to_base)
    #       do_request(:fund_cf => nil)
    #     end
    #     it "should assign false to @valid if the user doesn't choose a fund_cf option" do
    #       do_request(:fund_cf => nil)
    #       assigns[:valid].should be_false
    #     end
    #     it "should not save the order if the user doesn't choose a fund_cf option" do
    #       @order.should_receive(:save).never
    #       do_request(:fund_cf => nil)
    #     end
    #     
    #     it "should add an investment to the cart" do
    #       @cart.should_receive(:add_item).with(@admin_investment).and_return(@cart.items << @admin_investment)
    #       do_request
    #     end
    #     it "should not add an investment to the cart if there's an empty amount" do
    #       @admin_investment.should_receive(:amount?).and_return(false)
    #       @cart.should_receive(:add_item).never
    #       do_request
    #     end
    #     
    #     it "should calculate the amount based on params[:fund_cf_amount] when dollars are passed" do
    #       Investment.should_receive(:new).with(hash_including(:amount => "111"))
    #       do_request({:fund_cf_amount => "111"})
    #     end
    # 
    #     it "should calculate the amount based on cart.total and params[:fund_cf_amount] when percent are passed" do
    #       @cart.stub!(:total).and_return(200)
    #       Investment.should_receive(:new).with(hash_including(:amount => "5"))
    #       do_request({:fund_cf_amount => "5", :fund_cf => "percent"})
    #     end
    #     
    #     it "should remove admin_investment from the cart.items if it's in there" do
    #       @cart.add_item(@admin_investment)
    #       
    #       index = @cart.items.index(@admin_investment)
    #       @cart.should_receive(:remove_item).with(index)
    #       do_request
    #     end
    #     
    #     it "should replace an existing fund_cf in the @cart if one is already there" do
    #       @cart.add_item @admin_investment
    #       @cart.should_receive(:add_item).with(@admin_investment)
    #       do_request(:fund_cf => 'dollars', :fund_cf_amount => "10")
    #     end
    # 
    #     it "should remove an existing fund_cf in the @cart when params[:fund_cf] is \"no\"" do
    #       do_request({:fund_cf => "no"})
    #       @cart.items.select{|item| item.project_id == @admin_project.id && item.class == Investment }.should be_empty
    #     end
    # 
    #     def do_request(params = {})
    #       params = {:fund_cf => 'dollars', :fund_cf_amount => "10", :step => @step}.merge(params)
    #       put "update", params
    #     end
    #   end
    # end
    # 
    # describe "on the billing step" do
    #   before do
    #     @step = "billing"
    #     @user = mock_model(User, :valid? => true, :balance => 0)
    #     User.stub!(:new).and_return(@user)
    #     @order.stub!(:email?).and_return(true)
    #     @order.stub!(:email).and_return("email@example.com")
    #   end
    #   
    #   it "next_step should be 'confirm'" do
    #     do_request
    #     controller.send!(:next_step).should == "confirm"
    #   end
    #   it "should call do_billing" do
    #     controller.should_receive(:do_billing)
    #     do_request
    #   end
    #   describe "do_billing method" do
    #     it "should not create a new User" do
    #       User.should_receive(:new).never
    #       do_request
    #     end
    #     it "should create a new User when create_account is passed" do
    #       User.should_receive(:new).and_return(@user)
    #       do_request(:create_account => "1")
    #     end
    #     it "should save a valid user when create_account is passed" do
    #       @user.should_receive(:valid?).at_least(:once).and_return(true)
    #       @user.should_receive(:save)
    #       do_request(:create_account => "1")
    #     end
    #     it "should not save an invalid user when create_account is passed" do
    #       @user.should_receive(:valid?).and_return(false)
    #       do_request(:create_account => "1")
    #     end
    #     it "should not check if the email is a user login when create_account is passed" do
    #       User.should_receive(:find_by_login).never
    #       do_request(:create_account => "1")
    #     end
    #     it "should check if the email is a user login and add a flash.now[:notice] if it is" do
    #       User.should_receive(:find_by_login).with(@order.email).and_return(@user)
    #       do_request
    #       # there's no way to spec a flash.now[:notice] yet...
    #       # flash.now[:notice].should_not be_nil
    #     end
    #   end
    #   it "should save the order" do
    #     @order.should_receive(:save)
    #     do_request
    #   end
    #   it "should render the confirm step" do
    #     do_request
    #     response.should render_template("confirm")
    #   end
    #   it "should render billing template if it's not valid" do
    #     controller.should_receive(:validate_order).and_return(false)
    #     do_request
    #     response.should render_template("billing")
    #   end
    # end
    # 
    # describe "on the payment step" do
    #   before do
    #     @step = "payment"
    #   end
    #   it "should call do_payment" do
    #     controller.should_receive(:do_payment)
    #     do_request
    #   end
    #   it "next_step should be 'billing'" do
    #     do_request
    #     controller.send!(:next_step).should == "billing"
    #   end
    #   describe "do_payment method" do
    #     it "should not save the card_number in the session" do
    #       do_request(:order => {:card_number => 1234123412341234})
    #       session[:card_number].should be_nil
    #     end
    #     it "should not save the card_number if the order is invalid" do
    #       controller.should_receive(:validate_order).and_return(false)
    #       do_request(:order => {:card_number => 1234123412341234})
    #       session[:card_number].should be_nil
    #     end
    #     it "should not save the card_number if no card_number is passed" do
    #       do_request(:order => {:card_number => nil})
    #       session[:card_number].should be_nil
    #     end
    #   end
    #   it "should save the order" do
    #     @order.should_receive(:save)
    #     do_request
    #   end
    #   it "should redirect to billing step" do
    #     do_request
    #     response.should render_template("billing")
    #   end
    #   it "should render payment template if it's not valid" do
    #     controller.should_receive(:validate_order).and_return(false)
    #     do_request
    #     response.should render_template("payment")
    #   end
    #   
    #   describe "before_billing method" do
    #     before do
    #       controller.stub!(:validate_order).and_return(true)
    #       controller.stub!(:do_action).and_return(true)
    #       @gift = Gift.generate!
    #       @cart.add_item(@gift)
    #       # @cart.stub!(:gifts).and_return(@gifts)
    #     end
    #     it "should call before_billing if the order is valid" do
    #       controller.should_receive(:before_billing)
    #       do_request
    #     end
    #     # it "should grab the first gift and prepopulate the email address" do
    #     #   first_name, last_name = @gift.name.to_s.split(/ /, 2)
    #     #   @order.should_receive(:email?).and_return(false)
    #     #   @order.should_receive(:email=).with(@gift.email).and_return(true)
    #     #   @order.should_receive(:first_name?).and_return(false)
    #     #   @order.should_receive(:first_name=).with(first_name).and_return(true)
    #     #   @order.should_receive(:last_name?).and_return(false)
    #     #   @order.should_receive(:last_name=).with(last_name).and_return(true)
    #     #   do_request
    #     # end
    #   end
    # end

    describe "on the confirm step" do
      before do
        @step = "confirm"
        @order.stub!(:run_transaction).and_return(true)
        @gift.stub!(:send_at).and_return(false)
      end
      
      it "should call do_confirm" do
        controller.should_receive(:do_confirm)
        do_request
      end
      it "next_step should be nil" do
        do_request
        controller.send!(:next_step).should == nil
      end
      
      it "should redirect to dt_checkout_path if it's valid and complete" do
        controller.should_receive(:validate_order).and_return(true)
        controller.stub!(:do_action).and_return(true)
        @order.should_receive(:complete?).and_return(true)
        do_request
        response.should redirect_to(dt_checkout_path(:order_number => @order.order_number))
      end
      
      describe "do_confirm method" do
        it "should process the credit card" do
          @order = Order.new(:email => "user@example.com")
          controller.stub!(:find_order).and_return(@order)
          
          @order.total = 10
          @order.credit_card_payment = @order.total
          @order.should_receive(:run_transaction).and_return(true)
          do_request
        end
        it "should update the send_now on any stale gifts (with send_at values in the past)" do
          now = Time.now
          Time.stub!(:now).and_return(now)
          @gift = Gift.generate!(:send_email => true)
          @gift.stub!(:send_at).and_return(Time.now - 15.minutes)
          @cart.stub!(:gifts).and_return([@gift])
          @gift.should_receive(:send_at=).with(Time.now + 1.minute)
          do_request
        end
        it "should not update the send_now on any non-stale gifts (with send_at values in the future)" do
          now = Time.now
          Time.stub!(:now).and_return(now)
          @gift = Gift.generate!(:send_email => true)
          @gift.stub!(:send_at).and_return(Time.now + 3.seconds)
          @cart.stub!(:gifts).and_return([@gift])
          @gift.should_receive(:send_at=).never
          do_request
        end
        it "should not update the send_now on any gifts that aren't being sent (send_email = false)" do
          now = Time.now
          Time.stub!(:now).and_return(now)
          @gift = Gift.generate!(:send_email => false)
          @cart.stub!(:gifts).and_return([@gift])
          @gift.should_receive(:send_at=).never
          do_request
        end
        it "should save the gifts from the cart into the db" do
          @gift1 = Gift.generate!
          @gift2 = Gift.generate!
          @cart.should_receive(:gifts).twice.and_return([@gift1, @gift2])
          @order.should_receive(:gifts=).with([@gift1, @gift2])
          do_request
        end
        it "should save the investments from the cart into the db" do
          @investment1 = Investment.generate!
          @investment2 = Investment.generate!
          @cart.should_receive(:investments).and_return([@investment1, @investment2])
          @order.should_receive(:investments=).with([@investment1, @investment2])
          do_request
        end
        it "should save the deposits from the cart into the db" do
          @deposit1 = Deposit.generate!
          @deposit2 = Deposit.generate!
          @cart.should_receive(:deposits).and_return([@deposit1, @deposit2])
          @order.should_receive(:deposits=).with([@deposit1, @deposit2])
          do_request
        end
        it "should mark the order as complete" do
          @order.should_receive(:update_attributes!).with({:complete => true})
          do_request
        end
        it "should empty the cart" do
          @cart.should_receive(:empty!)
          do_request
        end
        it "should remove the order_id from the session" do
          session[:order_id] = 1
          do_request
          session[:order_id].should be_nil
        end
        it "should add the order_number into the session" do
          session[:order_number].should be_nil
          do_request
          session[:order_number].should == [@order.order_number]
        end
        it "should not process a credit card when not paying from it" do
          @order.stub!(:total).and_return(55)
          @order.stub!(:credit_card_payment).and_return(0)
          @order.should_receive(:run_transaction).never
          do_request
        end
        describe "when paying with a gift card" do
          before do
            @gift_card = Gift.generate!(:amount => @cart.total)
            controller.session[:gift_card_id] = @gift_card.id
            controller.session[:gift_card_balance] = @gift_card.balance
            @order.credit_card_payment = 0
            @order.total = @cart.total
            @order.gift_card_balance = @gift_card.balance
            @order.gift_card_payment = @gift_card.balance
          end
          it "should not run a credit card when paying with a gift card" do
            @order.should_receive(:run_transaction).never
            do_request
          end
          it "should add the gift_card_payment_id to the order when paying with a gift_card" do
            do_request
            @order.gift_card_payment_id.should == @gift_card.id
          end
          it "should save the gift_card_payment to the order when paying with a gift_card" do
            do_request
            @order.gift_card_payment.should == @gift_card.balance
          end
          it "should reduce the gift_card balance when paying with a gift_card" do
            do_request
            @gift_card.reload
            @gift_card.balance.should == @order.total - @order.gift_card_payment
          end
          it "should remove the gift_card_id from the session" do
            do_request
            controller.session[:gift_card_id].should be_nil
          end
          it "should remove the gift_card_balance from the session" do
            do_request
            controller.session[:gift_card_balance].should be_nil
          end
          it "should pickup the gift" do
            @gift_card.picked_up_at.should be_nil
            do_request
            @gift_card.reload
            @gift_card.picked_up_at.should_not be_nil
          end
        end
      end
      describe "do_confirm method with invalid transaction" do
        before do
          @order.stub!(:run_transaction).and_return(false)
          @order.total = 10
          @order.credit_card_payment = @order.total
        end
        it "should not mark the order as complete or save the deposits, investments or gifts if the transaction isn't successful" do
          @order.should_receive(:run_transaction).and_return(false)
          @order.should_receive(:update_attributes).never
          @order.should_receive(:gifts=).never
          @order.should_receive(:deposits=).never
          @order.should_receive(:investments=).never
          do_request
        end
        it "should not empty the cart, remove the order_id or add the order_number" do
          session[:order_id] = 1
          session[:order_number].should be_nil
          @cart.should_receive(:empty!).never
          do_request
          session[:order_id].should == 1
          session[:order_number].should be_nil
        end
      end
    end

    def do_request(params = {})
      params = {:step => @step}.merge(params)
      put "update", params
    end
  end
end
