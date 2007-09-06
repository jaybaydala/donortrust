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
  setup do
    @controller = Dt::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rs         = ActionController::Routing::Routes
  end
  
  specify "should recognize the routes" do
    @rs.generate(:controller => "dt/deposits", :action => "index").should.equal "/dt/deposits"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'index' } to /dt/deposits" do
    route_for(:controller => "dt/deposits", :action => "index").should == "/dt/deposits"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'show', :id => 1 } to /dt/deposits/1" do
    route_for(:controller => "dt/deposits", :action => "show", :id => 1).should == "/dt/deposits/1"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'new' } to /dt/deposits/new" do
    route_for(:controller => "dt/deposits", :action => "new").should == "/dt/deposits/new"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'create' } to /dt/deposits/new" do
    route_for(:controller => "dt/deposits", :action => "new").should == "/dt/deposits/new"
  end
    
  specify "should map { :controller => 'dt/deposits', :action => 'edit', :id => 1 } to /dt/deposits/1;edit" do
    route_for(:controller => "dt/deposits", :action => "edit", :id => 1).should == "/dt/deposits/1;edit"
    #dt_edit_deposit_path(1).should.not.throw
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'update', :id => 1} to /dt/deposits/1" do
    route_for(:controller => "dt/deposits", :action => "update", :id => 1).should == "/dt/deposits/1"
  end
  
  specify "should map { :controller => 'dt/deposits', :action => 'destroy', :id => 1} to /dt/deposits/1" do
    route_for(:controller => "dt/deposits", :action => "destroy", :id => 1).should == "/dt/deposits/1"
  end

  specify "should map { :controller => 'dt/deposits', :action => 'confirm'} to /dt/deposits/1" do
    route_for(:controller => "dt/deposits", :action => "confirm").should == "/dt/deposits;confirm"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Deposits index behaviour"do
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper

  setup do
    @controller = Dt::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "should redirect if !logged_in?" do
    get :index
    response.should.redirect
  end

  specify "should redirect to new if logged_in?" do
    login_as :quentin
    get :index
    response.should.redirect :action => 'new'
  end
end

context "Dt::Deposits new behaviour"do
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper
  
  setup do
    @controller = Dt::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "method should exist" do
    @controller.methods.should.include 'new'
  end

  specify "should redirect if !logged_in?" do
    get :new
    response.should.redirect
  end

  specify "should not redirect if logged_in?" do
    login_as :quentin
    get :new
    response.should.not.redirect
  end

  specify "should use 'new' template" do
    login_as :quentin
    get :new
    template.should.be 'dt/deposits/new'
  end

  specify "form should post to a confirmation page" do
    login_as :quentin
    get :new
    page.should.select "form[action=/dt/deposits;confirm][method=post]"
  end

  specify "should show form with the appropriate fields" do
    login_as :quentin
    get :new
    page.should.select "form[action=/dt/deposits;confirm][method=post]#depositform"
    assert_select "form#depositform input" do
      assert_select "[id=user_first_name]"
      assert_select "[id=user_last_name]"
      assert_select "[id=user_address]"
      assert_select "[id=user_city]"
      assert_select "[id=user_province]"
      assert_select "[id=user_postal_code]"
      assert_select "[id=user_country]"
      
      assert_select "[id=deposit_amount]"
      assert_select "[id=deposit_credit_card]"
      assert_select "[type=submit]"
    end
    assert_select "form#depositform select" do
      assert_select "[id=deposit_expiry_month]"
      assert_select "[id=deposit_expiry_year]"
    end
  end
end

context "Dt::Deposits confirm behaviour"do
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper
  
  setup do
    @controller = Dt::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def do_post(options = {})
    deposit_params = { :amount => 200.00, :credit_card => 4111111111111111,  :expiry_month => "04", :expiry_year => "09" }
    user_params = { :first_name => 'Timothy', :last_name => 'Glen' }
    # merge the options
    deposit_params.merge!(options[:deposit]) if options[:deposit]
    user_params.merge!(options[:user]) if options[:user]
    # do the post
    post :confirm, :deposit => deposit_params, :user => user_params
  end
  
  specify "should redirect if !logged_in?" do
    post :confirm
    response.should.redirect
  end
  
  specify "should respond to post" do
    login_as :quentin
    do_post
    response.should.not.redirect
    template.should.be "dt/deposits/confirm"
    page.should.select "form[action=/dt/deposits][method=post]#depositform"
    assert_select "form#depositform input" do |input|
      assert_select "[type=hidden][id=deposit_amount][value=200.00]"
      assert_select "[type=hidden][id=deposit_credit_card][value=4111111111111111]"
      assert_select "[type=submit]"
    end
  end

  specify "should redirect if there's no amount" do
    login_as :quentin
    post :confirm, :deposit => { :credit_card => 4111111111111111 }
    response.should.redirect :action => 'new'
  end

  specify "should redirect if there's no credit_card or card expiry date" do
    login_as :quentin
    do_post( :deposit => { :credit_card => nil } )
    response.should.redirect :action => 'new'
    do_post( :deposit => { :expiry_month => nil } )
    response.should.redirect :action => 'new'
    do_post( :deposit => { :expiry_year => nil } )
    response.should.redirect :action => 'new'
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
      assert_select "[type=button][onclick=javascript:history.go(-1);]"
    end
  end
end

context "Dt::Deposits create behaviour"do
  fixtures :deposits, :user_transactions, :users
  include DtAuthenticatedTestHelper
  setup do
    @controller = Dt::DepositsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  specify "method should exist" do
    @controller.methods.should.include 'create'
  end

  specify "should redirect if !logged_in" do
    create_deposit
    should.redirect
  end

  specify "should create a deposit" do
    login_as :quentin
    lambda {
      create_deposit
      should.redirect :controller => 'dt/accounts', :action => 'show', :id => users(:quentin).id
    }.should.change(Deposit, :count)
  end

  private
  def create_deposit(options = {})
    deposit_params = { :amount => 200.00, :credit_card => 4111111111111111,  :expiry_month => "04", :expiry_year => "09" }
    # merge the options
    deposit_params.merge!(options[:deposit]) if options[:deposit]
    # do the post
    post :create, :deposit => deposit_params
  end
end

context "Dt::Deposits show behaviour"do
  setup do
    @controller = Dt::DepositsController.new
  end
  
  specify "method should not exist" do
    @controller.methods.should.not.include 'show'
  end
end

context "Dt::Deposits edit behaviour"do
  setup do
    @controller = Dt::DepositsController.new
  end
  
  specify "method should not exist" do
    @controller.methods.should.not.include 'edit'
  end
end

context "Dt::Deposits update behaviour"do
  setup do
    @controller = Dt::DepositsController.new
  end
  
  specify "method should not exist" do
    @controller.methods.should.not.include 'update'
  end
end

context "Dt::Deposits destroy behaviour"do
  setup do
    @controller = Dt::DepositsController.new
  end
  
  specify "method should not exist" do
    @controller.methods.should.not.include 'destroy'
  end
end
