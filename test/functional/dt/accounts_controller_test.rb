require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/accounts_controller'

# Re-raise errors caught by the controller.
class Dt::AccountsController; def rescue_action(e) raise e end; end

context "Dt::Accounts inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::AccountsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Accounts #route_for" do
  use_controller Dt::AccountsController

  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should recognize the routes" do
    @rs.generate(:controller => "dt/accounts", :action => "index").should.equal "/dt/accounts"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'index' } to /dt/accounts" do
    route_for(:controller => "dt/accounts", :action => "index").should == "/dt/accounts"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'new' } to /dt/accounts/new" do
    route_for(:controller => "dt/accounts", :action => "new").should == "/dt/accounts/new"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'create' } to /dt/accounts" do
    route_for(:controller => "dt/accounts", :action => "create").should == "/dt/accounts"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'show', :id => 1 } to /dt/accounts/1" do
    route_for(:controller => "dt/accounts", :action => "show", :id => 1).should == "/dt/accounts/1"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'edit', :id => 1 } to /dt/accounts/1/edit" do
    route_for(:controller => "dt/accounts", :action => "edit", :id => 1).should == "/dt/accounts/1/edit"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'update', :id => 1} to /dt/accounts/1" do
    route_for(:controller => "dt/accounts", :action => "update", :id => 1).should == "/dt/accounts/1"
  end
  
  specify "should map { :controller => 'dt/accounts', :action => 'destroy', :id => 1} to /dt/accounts/1" do
    route_for(:controller => "dt/accounts", :action => "destroy", :id => 1).should == "/dt/accounts/1"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'activate'} to /dt/accounts/activate" do
    route_for(:controller => "dt/accounts", :action => "activate").should == "/dt/accounts/activate"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'activate', :id => 'code' } to /dt/accounts/activate?id=code" do
    route_for(:controller => "dt/accounts", :action => "activate", :id => 'code' ).should == "/dt/accounts/activate?id=code"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'resend' } to /dt/accounts/resend" do
    route_for(:controller => "dt/accounts", :action => "resend" ).should == "/dt/accounts/resend"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'reset' } to /dt/accounts/reset" do
    route_for(:controller => "dt/accounts", :action => "reset" ).should == "/dt/accounts/reset"
  end

  specify "should map { :controller => 'dt/accounts', :action => 'reset_password' } to /dt/accounts/reset_password" do
    route_for(:controller => "dt/accounts", :action => "reset_password" ).should == "/dt/accounts/reset_password"
  end
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Accounts handling GET /dt/accounts" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  def do_get
    get :index
  end
  
  specify "should get index if logged_in? or User.count > 0" do
    do_get
    response.should.not.redirect
    template.should.be "dt/accounts/index"
    User.destroy_all
    do_get
    response.should.redirect :action => 'new'
  end
end

context "Dt::Accounts handling GET /dt/accounts/1" do
  use_controller Dt::AccountsController
  fixtures :users, :projects, :partners, :places, :user_transactions, :orders, :gifts, :investments, :deposits
  include DtAuthenticatedTestHelper

  setup do
    @user = users(:quentin)
  end
  
  def do_get
    get :show, :id => @user.id
  end
  
  specify "should redirect to :signin if not logged_in?" do
    do_get
    response.should.redirect login_path
  end

  specify "should redirect to dt/accounts/id when logged_in? as different user" do
    login_as(:tim)
    do_get
    response.should.redirect :action => 'show', :id => users(:tim).id
  end

  specify "should not redirect when logged_in? as current_user" do
    login_as(:quentin)
    do_get
    response.should.not.redirect
  end

  specify "should get /dt/accounts/show/1" do
    login_as(:quentin)
    do_get
    template.should.be 'dt/accounts/show'
  end
  
  specify "should show all four types of transactions - orders and legacy gifts, investments and deposits" do
    login_as(:quentin)
    do_get
    page.should.select "div.orderTransaction"
    page.should.select "div.giftTransaction"
    page.should.select "div.depositTransaction"
    page.should.select "div.investmentTransaction"
  end

  specify "should show complete orders" do
    login_as(:quentin)
    do_get
    page.should.select "div#orderTransaction-1"
  end

  specify "should not show incomplete orders" do
    login_as(:quentin)
    do_get
    page.should.not.select "div#orderTransaction-2"
  end
  
  specify "if a deposit with a gift_id that does not have a project_id, should show depost" do
    login_as(:quentin)
    do_get
    page.should.select "div.depositTransaction#depositTransaction-1"
  end

  specify "if a deposit with a gift_id that has a project_id, should show deposit with link to project" do
    login_as(:quentin)
    do_get
    d = Deposit.find(3) # this is a picked up gift with a project_id
    page.should.select "div.depositTransaction#depositTransaction-#{d.id}"
  end
  
  specify "should show my project wishlist" do
    login_as(:quentin)
    u = users(:quentin)
    u.projects << Project.find(1)
    u.projects << Project.find(2)
    do_get
    assert_select "div#wishlist" do
      assert_select("li[class=wishlist-item]", 2)
      for wishlist in assigns(:user).my_wishlists do
        assert_select "a[href=/dt/accounts/1/my_wishlists/#{wishlist.id}]", :text => "REMOVE PROJECT"
      end
    end
  end

  specify "should show an empty project wishlist" do
    login_as(:quentin)
    u = users(:quentin)
    u.projects.clear
    do_get
    assert_select "div#wishlist" do
      assert_select "a[href=/dt/projects]", {:count => 1, :text => 'Add New Project'}
    end
  end

  specify "should show my project wishlist" do
    login_as(:quentin)
    u = users(:quentin)
    u.projects << Project.find(1)
    u.projects << Project.find(2)
    do_get
    assert_select "div#project-list" do
      assert_select("li[class=project-list-item]", 2)
      for investment in assigns(:user).investments do
        assert_select "a[href=/dt/investments/new?project_id=#{investment.project_id}]", :text => "INVEST IN THIS PROJECT"
      end
    end
  end

end

context "Dt::Accounts handling GET /dt/accounts/activate" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper
  
  specify "non-activated user should not authenticate" do
    User.authenticate('aaron@example.com', 'test').should.be.nil
  end

  specify "should activate user" do
    get :activate, :id => users(:aaron).activation_code
    users(:aaron).should.equal User.authenticate('aaron@example.com', 'test')
  end

  specify "user activation should make session[:tmp_user] nil" do
    get :activate, :id => users(:aaron).activation_code
    session[:tmp_user].should.be nil
  end
end

context "Dt::Accounts handling GET /dt/accounts/resend" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end

  def do_get
    get :resend
  end
  
  specify "should redirect to /dt/accounts" do
    do_get
    should.redirect dt_accounts_path()
  end
  
  specify "should send an email to session[:tmp_user] if not logged_in?" do
    create_user
    @emails.clear
    do_get
    @emails.length.should.equal 1
    # to is an array of email recipients
    @emails.first.to[0].should =~ User.find_by_id(session[:tmp_user]).login
    @emails.first.subject.should =~ /Uend: Account Email Confirmation/
    @emails.first.body.should    =~ /To confirm your email and activate your account, please follow the link below/
  end
  
  specify "should send an email to current_user.login if logged_in?" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :user => {:login => 'newemail@example.com' } }
    @emails.clear
    do_get
    @emails.length.should.equal 1
    @emails.first.to[0].should =~ 'newemail@example.com'
    @emails.first.subject.should =~ /Uend: Account Email Confirmation/
    @emails.first.body.should    =~ /To confirm your email and activate your account, please follow the link below/
  end

  protected
  def create_user(options = {})
    post :create, :user => { :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirey', :password => 'quire', :password_confirmation => 'quire', :terms_of_use => '1', :country => 'Canada' }.merge(options)
  end
end

context "Dt::Accounts user activation mailer" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end

  specify "should activate user and send activation email" do
    get :activate, :id => users(:aaron).activation_code
    @emails.length.should.equal 1
    @emails.first.subject.should =~ /Your account has been activated/
    @emails.first.body.should    =~ /#{assigns(:user).name}, your account has been activated/
  end

  specify "should send activation email after signup" do
    create_user
    @emails.length.should.equal 1
    @emails.first.subject.should =~ /The future is here./
    @emails.first.body.should    =~ /Username: quire@example\.com/
    @emails.first.body.should    =~ /Password: quire/
    @emails.first.body.should    =~ /dt\/accounts\/activate\?id=#{assigns(:user).activation_code}/
  end

  protected
  def create_user(options = {})
    post :create, :user => { :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirey', :password => 'quire', :password_confirmation => 'quire', :terms_of_use => '1', :country => 'Canada' }.merge(options)
  end
end

context "Dt::Accounts handling GET /dt/accounts/new" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  def do_get
    get :new
  end

  specify "should render dt/accounts/new template if not logged_in?" do
    do_get
    template.should.be "dt/accounts/new"
  end
  
  specify "should redirect if logged_in?" do
    login_as :quentin
    do_get
    should.redirect
  end

  specify "should have a form set to post to /dt/accounts" do
    do_get
    page.should.select "form[action=/dt/accounts][method=post]"
  end

  specify "should have a form set to post to /dt/accounts" do
    do_get
    assert_select "form[action=/dt/accounts][method=post]" do
      assert_select "input[type=checkbox]#user_terms_of_use"
    end
  end
end

context "Dt::Accounts handling POST /dt/accounts/create" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  specify "should allow signup" do
    lambda {
      create_user
      should.redirect
    }.should.change(User, :count)
  end

  specify "should require login on signup" do
    lambda {
      create_user(:login => nil)
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should require password on signup" do
    lambda {
      create_user(:password => nil)
      assigns(:user).errors.on(:password).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should require password_confirmation on signup" do
    lambda {
      create_user(:password_confirmation => nil)
      assigns(:user).errors.on(:password_confirmation).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should require terms_of_use to be passed" do
    lambda {
      create_user(:terms_of_use => nil)
      assigns(:user).errors.on(:terms_of_use).should.not.be.nil
    }.should.not.change(User, :count)
  end
  specify "should require terms_of_use to be '1'" do
    lambda {
      create_user(:terms_of_use => 0)
      assigns(:user).errors.on(:terms_of_use).should.not.be.nil
    }.should.not.change(User, :count)
    lambda {
      create_user(:terms_of_use => '1')
      assigns(:user).errors.on(:terms_of_use).should.be.nil
    }.should.change(User, :count)
  end

  specify "should require valid email as login on signup" do
    lambda {
      create_user(:login => 'timglen')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success

      create_user(:login => 'timglen@pivotib')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
    
      create_user(:login => '@pivotib.com')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
    
      create_user(:login => 'pivotib.com')
      assigns(:user).errors.on(:login).should.not.be.nil
      status.should.be :success
    }.should.not.change(User, :count)
  end

  specify "should make session[:tmp_user] available on create" do
    create_user
    session[:tmp_user].should.not.be nil
  end
  
  specify "should not log in automatically" do
    create_user
    @controller.send('logged_in?').should.be false
  end

  protected
  def create_user(options = {})
    post :create, :user => { :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirey', :password => 'quire', :password_confirmation => 'quire', :terms_of_use => '1', :country => 'Canada' }.merge(options)
  end
end

context "Dt::Accounts handling GET /dt/accounts/1/edit" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  def do_get
    get :edit, :id => 1
  end
  
  specify "should redirect to signin if not logged in" do
    do_get
    should.redirect login_path
  end

  specify "should redirect if trying to edit other than current_user" do
    login_as :aaron
    do_get
    should.redirect
  end

  specify "should render if trying to edit current_user" do
    login_as :quentin
    do_get
    should.not.redirect
    template.should.be "dt/accounts/edit"
  end

  specify "should render the form" do
    login_as :quentin
    do_get
    page.should.select "form#userform"
    page.should.select "input#user_login"
    #page.should.select "input[type=submit]"
  end

  specify "should have a form set to put to /dt/accounts/1" do
    login_as :quentin
    do_get
    page.should.select "form[action=/dt/accounts/1]"
    assert_select "form#userform" do
      #assert_select "input[type=submit]"
    end
  end
  
  specify "form should have an old_password, password and password_confirmation fields" do
    login_as :quentin
    do_get
    page.should.select "form#userform input[name=old_password]"
    page.should.select "input#user_password"
    page.should.select "input#user_password_confirmation"
  end
end

context "Dt::Accounts handling PUT /dt/accounts/1/update" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end
  
  specify "should redirect to signin if not logged_in?" do
    @user = User.find(1)
    put :update, { :id => @user.id, :user => { :login => @user.login } }
    should.redirect_to login_path
  end

  specify "should not redirect to signin if logged_in?" do
    login_as :quentin
    @user = User.find(1)
    put :update, { :id => @user.id, :user => { :first_name => 'Tim' } }
    should.redirect_to :action => 'index'
  end
  
  specify "should redirect to edit if not current_user" do
    login_as :quentin
    @user = User.find(2)
    put :update, { :id => @user.id , :user => { :first_name => 'Tim' } }
    should.redirect
  end

  specify "should update your user if logged in and you're the current user" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :user => { :first_name => 'Tim' } }
    u.first_name.should.not.equal User.find(1).first_name
    should.redirect_to :action => 'index'
  end

  specify "should allow a password change" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :old_password => 'test', :user => {:password => 'new_password', :password_confirmation => 'new_password' } }
    u.crypted_password.should.not.equal User.find(1).crypted_password
  end

  specify "non-matching passwords should not change" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :old_password => 'test', :user => {:password => 'new_password', :password_confirmation => 'another_password' } }
    u.crypted_password.should.equal User.find(1).crypted_password
  end

  specify "empty old_password should not change password" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :user => {:password => 'new_password', :password_confirmation => 'new_password' } }
    u.crypted_password.should.equal User.find(1).crypted_password
  end

  specify "incorrect old_password should not change password" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :old_password => 'incorrect_password', :user => {:password => 'new_password', :password_confirmation => 'new_password' } }
    u.crypted_password.should.equal User.find(1).crypted_password
  end

  specify "should send a confirmation email if the email address is changed" do
    login_as :quentin
    u = User.find(1)
    put :update, { :id => u.id, :user => {:login => 'newemail@example.com' } }
    @emails.length.should.equal 1
    @emails.first.subject.should =~ /Uend: Account Email Confirmation/
    @emails.first.body.should    =~ /To confirm your email and activate your account, please follow the link below/
    @emails.first.body.should    =~ /\/dt\/accounts\/activate\?id=[A-za-z0-9]+/
  end
end

context "Dt::Accounts handling PUT /dt/accounts/1/reset_password" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper
  
  specify "should contain a form" do
    get :reset
    template.should.be 'dt/accounts/reset'
    assert_select "form[action=/dt/accounts/reset_password]#resetform" do
      assert_select "input[type=text][name=login]"
      assert_select "input[type=submit]"
    end
  end

end

context "Dt::Accounts handling PUT /dt/accounts/1/reset_password" do
  use_controller Dt::AccountsController
  fixtures :users
  include DtAuthenticatedTestHelper

  setup do
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end

  specify "an invalid login should show reset template and have a flash[:error]" do
    put :reset_password, :login => 'foo@example.com'
    template.should.be 'dt/accounts/reset'
    flash[:error].should.not.be.nil
  end  
  
  specify "a valid login should reset the password, send an email, redirect to login_path and contain a flash[:notice]" do
    put :reset_password, :login => 'quentin@example.com'
    assigns(:user).password.should.not.be nil
    @emails.length.should.equal 1
    should.redirect login_path
    flash[:notice].should.not.be nil
  end
end

#As a user I want to be able to retrieve my password so I won't forget it:
#  - creates a new password
#  - sends email to user's email address with new password
#  - on login, required to change the password to something rememberable
