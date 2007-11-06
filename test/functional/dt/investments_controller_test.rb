require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/investments_controller'

# Re-raise errors caught by the controller.
class Dt::InvestmentsController; def rescue_action(e) raise e end; end

context "Dt::Investments inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::InvestmentsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Investments #route_for" do
  use_controller Dt::InvestmentsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should recognize the routes" do
    @rs.generate(:controller => "dt/investments", :action => "index").should.equal "/dt/investments"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'index' } to /dt/investments" do
    route_for(:controller => "dt/investments", :action => "index").should == "/dt/investments"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'show', :id => 1 } to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "show", :id => 1).should == "/dt/investments/1"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'new' } to /dt/investments/new" do
    route_for(:controller => "dt/investments", :action => "new").should == "/dt/investments/new"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'create' } to /dt/investments/new" do
    route_for(:controller => "dt/investments", :action => "new").should == "/dt/investments/new"
  end
    
  specify "should map { :controller => 'dt/investments', :action => 'edit', :id => 1 } to /dt/investments/1;edit" do
    route_for(:controller => "dt/investments", :action => "edit", :id => 1).should == "/dt/investments/1;edit"
    #dt_edit_deposit_path(1).should.not.throw
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'update', :id => 1} to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "update", :id => 1).should == "/dt/investments/1"
  end
  
  specify "should map { :controller => 'dt/investments', :action => 'destroy', :id => 1} to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "destroy", :id => 1).should == "/dt/investments/1"
  end

  specify "should map { :controller => 'dt/investments', :action => 'confirm'} to /dt/investments/1" do
    route_for(:controller => "dt/investments", :action => "confirm").should == "/dt/investments;confirm"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::InvestmentsController index, show, edit, update and destroy should not exist" do
  use_controller Dt::InvestmentsController
  specify "method should not exist" do
    %w( index show edit update destroy ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end

context "Dt::InvestmentsController new, confirm and create should exist" do
  use_controller Dt::InvestmentsController
  specify "method should exist" do
    %w( new confirm create ).each do |m|
      @controller.methods.should.include m
    end
  end
end

context "Dt::InvestmentsController new behaviour" do
  use_controller Dt::InvestmentsController
  fixtures :investments, :users, :projects, :groups, :partners
  include DtAuthenticatedTestHelper
  
  specify "should redirect if !logged_in?" do
    get :new, :project_id => Project.find_public(:first)
    status.should.be :redirect
  end

  specify "should respond" do
    login_as :quentin
    get :new, :project_id => Project.find_public(:first)
    status.should.be :success
  end

  specify "should assign @investment" do
    login_as :quentin
    get :new, :project_id => Project.find_public(:first)
    #assigns(:tax_receipt).should.not.be.nil
    assigns(:investment).should.not.be.nil
  end

  specify "body should contain a form#investmentform" do
    login_as :quentin
    get :new, :project_id => Project.find_public(:first)
    assert_select "form#investmentform"
  end

  specify "form should :post to /dt/investments;confirm" do
    login_as :quentin
    get :new, :project_id => Project.find_public(:first)
    assert_select "form#investmentform[method=post][action=/dt/investments;confirm]"
  end

  specify "form#investmentform should contain the proper inputs" do
    login_as :quentin
    project = Project.new
    project.stubs(:name).returns('First Project')
    project.stubs(:id).returns(1)
    get :new, :project_id => project.id
    assert_select "form#investmentform" do
      assert_select "input[type=radio]#investment_project_id_#{project.id}"
      assert_select "input[type=text]#investment_amount"
      assert_select "input[type=checkbox]#fund_cf"
      assert_select "input[type=submit]"
    end
  end
  
  specify "if Project.cf_unallocated_project exists, should show a radio button for it" do
    login_as :quentin
    unallocated_project = Project.new
    unallocated_project.stubs(:name).returns('Unallocated Project')
    unallocated_project.stubs(:id).returns(999999)
    Project.stubs(:cf_unallocated_project).returns(unallocated_project)
    project = Project.new
    project.stubs(:name).returns('First Project')
    project.stubs(:id).returns(1)
    get :new, :project_id => project.id
    assert_select "form#investmentform" do
      assert_select "input[type=radio]#investment_project_id_#{unallocated_project.id}"
      assert_select "input[type=radio]#investment_project_id_#{project.id}"
    end
  end

  specify "if Project.cf_unallocated_project exists and no project_id is passed the radio button should be selected and we should give the option to find a project" do
    login_as :quentin
    unallocated_project = Project.new
    unallocated_project.stubs(:name).returns('Unallocated Project')
    unallocated_project.stubs(:id).returns(999999)
    Project.stubs(:cf_unallocated_project).returns(unallocated_project)
    get :new
    assert_select "form#investmentform" do
      assert_select "input[type=radio][checked=checked]#investment_project_id_#{unallocated_project.id}"
      assert_select "a[href=/dt/projects]", :text => %r(find a different project)i
    end
  end
end

context "Dt::InvestmentsController confirm behaviour" do
  use_controller Dt::InvestmentsController
  fixtures :investments, :users, :projects, :groups, :partners
  include DtAuthenticatedTestHelper
  
  specify "should redirect if !logged_in?" do
    do_post
    status.should.be :redirect
  end

  specify "should respond" do
    login_as :quentin
    do_post
    status.should.be :success
  end

  specify "should assign @investment" do
    login_as :quentin
    get :new
    assigns(:investment).should.not.be.nil
  end

  specify "should use dt/investments/confirm" do
    login_as :quentin
    do_post
    template.should.be 'dt/investments/confirm'
  end

  specify "body should contain a form#investmentform" do
    login_as :quentin
    do_post
    assert_select "form#investmentform"
  end

  specify "form should :post to /dt/investments" do
    login_as :quentin
    do_post
    assert_select "form#investmentform[method=post][action=/dt/investments]"
  end

  specify "form#investmentform should contain the proper inputs" do
    login_as :quentin
    do_post
    assert_select "form#investmentform" do
      assert_select "input[type=hidden]#investment_project_id"
      assert_select "input[type=hidden]#investment_amount"
      assert_select "input[type=submit]"
      assert_select "input[type=button][onclick=history.go(-1);]"
    end
  end
  
  specify "should give dt/investments/new template if amount is invalid" do
    login_as :quentin
    do_post :investment => { :amount => nil } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => 'hi' } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => 0 } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => -1 } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => 1 } 
    template.should.be 'dt/investments/confirm'
  end

  specify "should give dt/investments/new template if project_id is invalid" do
    login_as :quentin
    do_post :investment => { :project_id => nil } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :project_id => 'hi' } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :project_id => 0 } 
    template.should.be 'dt/investments/new'
    do_post :investment => { :project_id => 1 } 
    template.should.be 'dt/investments/confirm'
  end

  private
  def do_post(options = {})
    investment_params = { :project_id => 1, :amount => 1 }
    investment_params.merge!(options[:investment]) if options[:investment]
    post :confirm, { :investment => investment_params }
  end
end

context "Dt::InvestmentsController create behaviour" do
  use_controller Dt::InvestmentsController
  fixtures :investments, :users, :projects, :groups, :partners
  include DtAuthenticatedTestHelper
  
  specify "should redirect if !logged_in?" do
    do_post
    status.should.be :redirect
  end

  specify "should redirect to dt/accounts/1" do
    login_as :quentin
    do_post
    should.redirect :controller => 'dt/accounts', :action => 'show', :id => users(:quentin).id
  end

  specify "should create a new Investment" do
    login_as :quentin
    lambda {
      do_post
    }.should.change(Investment, :count)
  end
  
 specify "should create a new Investment and CF Investment" do
    login_as :quentin
    old_count = Investment.count
    do_post({:amount =>20}, fund_cf = true)
    Investment.count.should.equal old_count+2
  end
  
  specify "should create a new UserTransaction" do
    login_as :quentin
    lambda {
      do_post
    }.should.change(UserTransaction, :count)
  end

  specify "should add a flash[:notice]" do
    login_as :quentin
    do_post
    flash[:notice].should.not.be.blank
  end

  specify "should show dt/investments/new with an invalid amount" do
    login_as :quentin
    do_post :investment => { :amount => -1 }
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => 'hi' }
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => 10_000_000_000 }
    template.should.be 'dt/investments/new'
    do_post :investment => { :amount => 0 }
    template.should.be 'dt/investments/new'
  end

  specify "should show dt/investments/new with an invalid project_id" do
    login_as :quentin
    do_post :investment => { :project_id => -1 }
    template.should.be 'dt/investments/new'
    do_post :investment => { :project_id => 'hi' }
    template.should.be 'dt/investments/new'
    do_post :investment => { :project_id => 0 }
    template.should.be 'dt/investments/new'
  end

  private
  def do_post(options = {}, fund_cf = false)
    tax_receipt_params = {}
    %w( first_name last_name address city province postal_code country ).each do |field|
      tax_receipt_params[field.to_sym] = users(:quentin).send(field)
    end
    investment_params = { :project_id => 1, :amount => 1 }
    investment_params.merge!(options[:investment]) if options[:investment]
    post :create, { :investment => investment_params, :fund_cf => fund_cf }
  end
end