require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/deposits_controller'

# Re-raise errors caught by the controller.
class Dt::DepositsController; def rescue_action(e) raise e end; end

context "Dt::Deposits inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::DepositsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Deposits #route_for" do
  use_controller Dt::DepositsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'index' } to /dt/accounts/1/deposits" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "index").should == "/dt/accounts/1/deposits"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'show', :id => 1 } to /dt/accounts/1/deposits/1" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "show", :id => 1).should == "/dt/accounts/1/deposits/1"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'new' } to /dt/accounts/1/deposits/new" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "new").should == "/dt/accounts/1/deposits/new"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'create' } to /dt/accounts/1/deposits/new" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "new").should == "/dt/accounts/1/deposits/new"
  end
    
  specify "should map { :controller => 'dt/deposits', :action => 'edit', :id => 1 } to /dt/accounts/1/deposits/1;edit" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "edit", :id => 1).should == "/dt/accounts/1/deposits/1;edit"
    #dt_edit_deposit_path(1).should.not.throw
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'update', :id => 1} to /dt/accounts/1/deposits/1" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "update", :id => 1).should == "/dt/accounts/1/deposits/1"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'destroy', :id => 1} to /dt/accounts/1/deposits/1" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "destroy", :id => 1).should == "/dt/accounts/1/deposits/1"
  end

  specify "should map { :controller => 'dt/deposits', :action => 'confirm'} to /dt/accounts/1/deposits/1" do
    route_for(:controller => "dt/deposits", :account_id => 1, :action => "confirm").should == "/dt/accounts/1/deposits;confirm"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Deposits new behaviour"do
  use_controller Dt::DepositsController
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper
  
  specify "method should exist" do
    @controller.methods.should.include 'new'
  end

  specify "should redirect if !logged_in?" do
    get :new, :account_id => users(:quentin).id
    response.should.redirect
  end

  specify "should not redirect if logged_in?" do
    login_as :quentin
    get :new, :account_id => users(:quentin).id
    response.should.not.redirect
  end

  specify "should assign deposit" do
    login_as :quentin
    get :new, :account_id => users(:quentin).id
    assigns(:deposit).should.not.be.nil
  end

  specify "should use 'new' template" do
    login_as :quentin
    get :new, :account_id => users(:quentin).id
    template.should.be 'dt/deposits/new'
  end

  specify "form should post to a confirmation page" do
    login_as :quentin
    get :new, :account_id => users(:quentin).id
    page.should.select "form[action=/dt/accounts/1/deposits;confirm][method=post]"
  end

  specify "should show form with the appropriate fields" do
    login_as :quentin
    get :new, :account_id => users(:quentin).id
    page.should.select "form[action=/dt/accounts/1/deposits;confirm][method=post]#depositform"
    assert_select "form#depositform input" do
      assert_select "[id=deposit_first_name]"
      assert_select "[id=deposit_last_name]"
      assert_select "[id=deposit_address]"
      assert_select "[id=deposit_city]"
      assert_select "[id=deposit_province]"
      assert_select "[id=deposit_postal_code]"
      
      assert_select "[id=deposit_amount]"
      assert_select "[id=deposit_credit_card]"
      assert_select "[type=submit]"
    end
    assert_select "form#depositform select" do
      assert_select "[id=deposit_country]"
      assert_select "[id=deposit_expiry_month]"
      assert_select "[id=deposit_expiry_year]"
    end
  end

  specify "should use session[:deposit_params] if they're available" do
    login_as :quentin
    @request.session[:deposit_params] = {:amount => 25, :first_name => 'Tester'}
    get :new, :account_id => users(:quentin).id
    session[:deposit_params].should == @request.session[:deposit_params]
    assigns(:deposit).amount.should == 25
    assigns(:deposit).first_name.should == "Tester"
  end
end

context "Dt::Deposits confirm behaviour"do
  use_controller Dt::DepositsController
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper
  
  specify "should redirect if !logged_in?" do
    post :confirm, :account_id => users(:quentin).id
    response.should.redirect
  end
  
  specify "should respond to post" do
    login_as :quentin
    do_post
    response.should.not.redirect
    template.should.be "dt/deposits/confirm"
    page.should.select "form[action=/dt/accounts/1/deposits][method=post]#depositform"
    inputs = %w( input#deposit_amount input#deposit_first_name input#deposit_last_name input#deposit_address input#deposit_city input#deposit_province input#deposit_postal_code input#deposit_country input#deposit_credit_card input#deposit_card_expiry )
    assert_select "form#depositform input" do
      inputs.each {|f|
        assert_select f
      }
      assert_select "input[type=submit]"
    end
  end

  specify "should use new template if there's no first_name, last_name, address, city, province, postal_code, country, amount, credit_card, expiry_month or expiry_year" do
    login_as :quentin
    %w(first_name last_name address city province postal_code country amount credit_card expiry_month expiry_year).each {|f|
      do_post :deposit => { f.to_sym => nil }
      template.should.be 'dt/deposits/new'
    }
  end

  specify "should use new template if !valid?" do
    login_as :quentin
    do_post( :deposit => { :expiry_month => "01", :expiry_year => "06" } )
    template.should.be "dt/deposits/new"
    do_post( :deposit => { :credit_card => 4111111111111111112 } )
    template.should.be "dt/deposits/new"
  end

  specify "should contain a link back to the previous page" do
    login_as :quentin
    do_post
    assert_select "form#depositform input" do |input|
      assert_select "[type=button][onclick=history.go(-1);]"
    end
  end
  
  specify "should assign deposit" do
    login_as :quentin
    do_post
    assigns(:deposit).should.not.be.nil
  end

  specify "should assign cf_investment if fund_cf is true" do
    login_as :quentin
    do_post({:deposit => {:amount => 100}}, true, 5)
    assigns(:cf_investment).should.not.be.nil
  end

  specify "should assign cf_investment with the proper amount if fund_cf is true" do
    login_as :quentin
    do_post({:deposit => {:amount => 100}}, true, 5)
    assigns(:cf_investment).amount.should == 5
  end

  specify "should assign total_amount with the proper amount if fund_cf is true" do
    login_as :quentin
    do_post({:deposit => {:amount => 100}}, true, 5)
    assigns(:total_amount).should == 105
  end

  specify "deposit amount should be amount + percentage if fund_cf is true" do
    login_as :quentin
    do_post({:deposit => {:amount => 100}}, true, 5)
    assigns(:deposit).amount.should.equal 105
  end

  specify "should put params into session" do
    login_as :quentin
    do_post
    session[:deposit_params].should == @controller.params[:deposit]
  end
  
  private
  def do_post(options = {}, fund_cf = false, fund_cf_percentage = 5)
    deposit_params = { :amount => 200.00, :first_name => 'Tim', :last_name => 'Glen', :address => '36 Example St.', :city => 'Guelph', :province => 'ON', :postal_code => 'N1E 7C5', :country => 'CA', :credit_card => 4111111111111111,  :expiry_month => "04", :expiry_year => "09" }
    # merge the options
    deposit_params.merge!(options[:deposit]) if options[:deposit]
    # do the post
    params = {:account_id => users(:quentin).id, :deposit => deposit_params}
    params[:fund_cf] = 1 if fund_cf
    params[:fund_cf_percentage] = fund_cf_percentage if fund_cf
    post :confirm, params
  end
end

context "Dt::Deposits create behaviour"do
  use_controller Dt::DepositsController
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper
  
  specify "method should exist" do
    @controller.methods.should.include 'create'
  end

  specify "should redirect if !logged_in" do
    create_deposit
    should.redirect
  end

  specify "should create a deposit and redirect to the user's account page" do
    login_as :quentin
    lambda {
      create_deposit
      should.redirect :controller => 'dt/accounts', :action => 'show', :id => users(:quentin).id
    }.should.change(Deposit, :count)
  end
  
  specify "a tax_receipt record should be created on deposit" do
    login_as :quentin
    lambda {
      create_deposit
    }.should.change(TaxReceipt, :count)
  end

  specify "a tax_receipt record should be created on deposit" do
    login_as :quentin
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
    create_deposit
    @emails.size.should == 1
  end

  specify "should create an investment if fund_cf is true" do
    login_as :quentin
    lambda {
      create_deposit({:amount => 100}, true, 5)
    }.should.change(Investment, :count)
  end

  specify "should assign cf_investment if fund_cf is true" do
    login_as :quentin
    create_deposit({:amount => 100}, true, 5)
    assigns(:cf_investment).should.not.be nil
  end

  specify "should create cf_investment with an amount of 5.0 if fund_cf is true" do
    login_as :quentin
    create_deposit({:amount => 100}, true, 5)
    assigns(:cf_investment).amount.should.equal 5
  end

  specify "deposit amount should be amount + percentage if fund_cf is true" do
    login_as :quentin
    create_deposit({:amount => 100}, true, 5)
    assigns(:deposit).amount.should.equal 105
  end

  specify "should remove deposit_params into session" do
    login_as :quentin
    @request.session[:deposit_params] = "test"
    create_deposit
    session[:deposit_params].should.be.nil
  end

  private
  def create_deposit(options = {}, fund_cf = false, fund_cf_percentage = 5)
    deposit_params = { :amount => 200.00, :first_name => 'Timothy', :last_name => 'Glen', :address => '36 Hill Trail', :city => 'Guelph', :province => 'ON', :postal_code => 'N1E 7C5', :country => 'Canada', :credit_card => 4111111111111111,  :expiry_month => "04", :expiry_year => "09" }
    # merge the options
    deposit_params.merge!(options) if options
    # do the post
    params = {:account_id => users(:quentin).id, :deposit => deposit_params}
    params[:fund_cf] = 1 if fund_cf
    params[:fund_cf_percentage] = fund_cf_percentage if fund_cf
    post :create, params
  end
end

context "Dt::Deposits index, show, edit, update and destroy should not exist"do
  use_controller Dt::DepositsController
  specify "method should not exist" do
    %w( index show edit update destroy ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end
