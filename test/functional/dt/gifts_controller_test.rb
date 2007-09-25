require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/gifts_controller'

# Re-raise errors caught by the controller.
class Dt::GiftsController; def rescue_action(e) raise e end; end

context "Dt::Gifts inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::GiftsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Gifts #route_for" do
  use_controller Dt::GiftsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'index' } to /dt/gifts" do
    route_for(:controller => "dt/gifts", :action => "index").should == "/dt/gifts"
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'show', :id => 1 } to /dt/gifts/1" do
    route_for(:controller => "dt/gifts", :action => "show", :id => 1).should == "/dt/gifts/1"
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'new' } to /dt/gifts/new" do
    route_for(:controller => "dt/gifts", :action => "new").should == "/dt/gifts/new"
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'create' } to /dt/gifts" do
    route_for(:controller => "dt/gifts", :action => "create").should == "/dt/gifts"
  end
    
  specify "should map { :controller => 'dt/gifts', :action => 'edit', :id => 1 } to /dt/gifts/1;edit" do
    route_for(:controller => "dt/gifts", :action => "edit", :id => 1).should == "/dt/gifts/1;edit"
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'update', :id => 1} to /dt/gifts/1" do
    route_for(:controller => "dt/gifts", :action => "update", :id => 1).should == "/dt/gifts/1"
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'destroy', :id => 1} to /dt/gifts/1" do
    route_for(:controller => "dt/gifts", :action => "destroy", :id => 1).should == "/dt/gifts/1"
  end

  specify "should map { :controller => 'dt/gifts', :action => 'confirm'} to /dt/gifts/1" do
    route_for(:controller => "dt/gifts", :action => "confirm").should == "/dt/gifts;confirm"
  end

  specify "should map { :controller => 'dt/gifts', :action => 'open'} to /dt/gifts;open" do
    route_for(:controller => "dt/gifts", :action => "open").should == "/dt/gifts;open"
  end
  
  specify "should map { :controller => 'dt/gifts', :action => 'unwrap', :id => 1} to /dt/gifts/1;unwrap" do
    route_for(:controller => "dt/gifts", :action => "unwrap", :id => 1).should == "/dt/gifts/1;unwrap"
  end

  specify "should map { :controller => 'dt/gifts', :action => 'preview'} to /dt/gifts;preview" do
    route_for(:controller => "dt/gifts", :action => "preview").should == "/dt/gifts;preview"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Gifts new, create, confirm, open, unwrap and preview should exist "do
  use_controller Dt::GiftsController
  specify "methods should exist" do
    %w( new create confirm open unwrap preview ).each do |m|
      @controller.methods.should.include m
    end
  end
end

context "Dt::Gifts index behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users
  include DtAuthenticatedTestHelper

  specify "index should redirect to new" do
    get :index
    should.redirect :action => 'new'
  end

 specify "index should redirect to new when logged_in?" do
    login_as :quentin
    get :index
    should.redirect :action => 'new'
  end
end

context "Dt::Gifts new behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should not redirect whether you're logged_in? or not" do
    get :new
    should.not.redirect
    login_as :quentin
    get :new
    should.not.redirect
  end

  specify "should assign the dt/gifts javascript to @action_js" do
    get :new
    assigns(:action_js).should.equal 'dt/ecards'
  end

  specify "should show form#giftform with the appropriate attributes" do
    get :new
    page.should.select "form[action=/dt/gifts;confirm][method=post]#giftform"
  end

  specify "form output should always contain amount, to_name, to_email, credit_card, card_expiry fields, comments" do
    # !logged_in?
    get :new
    inputs = %w( input#gift_amount input#gift_name input#gift_email input#gift_email_confirmation input#gift_to_name 
                 input#gift_to_email input#gift_to_email_confirmation textarea#gift_message 
                 select#gift_send_at_1i select#gift_send_at_2i select#gift_send_at_3i select#gift_send_at_4i select#gift_send_at_5i 
                 input#gift_credit_card select#gift_expiry_month select#gift_expiry_year input#gift_first_name input#gift_last_name 
                 input#gift_address input#gift_city input#gift_province input#gift_postal_code input#gift_country )
    assert_select "#giftform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
    # logged_in?
    login_as :quentin
    get :new
    assert_select "#giftform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
  end

  specify "first_name last_name address city province postal_code country email and name fields should match the current_user model values" do
    login_as :quentin
    get :new
    fields = %w( first_name last_name address city province postal_code country email )
    assert_select "#giftform" do
      fields.each do |field|
        value = users(:quentin).send(field)
        assert_select "input#gift_#{field}[value=#{value}]" if value != nil
      end
      assert_select "input#gift_name[value=#{users(:quentin).full_name}]"
    end
  end
  
  specify "output should contain input#gift_name and input#gift_email" do
    get :new
    page.should.select "#giftform input#gift_name"
    page.should.select "#giftform input#gift_email"
    login_as :quentin
    get :new
    page.should.select "#giftform input#gift_name"
    page.should.select "#giftform input#gift_email"
  end

  specify "if logged_in?, give a choice to use your account or a credit_card" do
    login_as :quentin
    get :new
    page.should.select "#giftform input[type=radio][name=payment][value=account]"
    page.should.select "#giftform input[type=radio][name=payment][value=credit]"
    page.should.select "#giftform #credit_payment[style=display:none;]"
    page.should.select "#giftform #account_payment[style=display:none;]"
  end

  specify "if project_id is passed, should show the project" do
    get :new, :project_id => 1
    page.should.select "#giftform input[type=hidden]#gift_project_id"
  end

  specify "if project_id is not passed, should suggest giving a project" do
    get :new
    page.should.select "#giftform #projectsuggest a[href=/dt/search]"
  end
  
  specify "should contain a preview submit button" do
    get :new
    page.should.select "#giftform input[type=button]#gift_preview"
  end

end


context "Dt::Gifts preview behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify 'should have @gift and @gift_mail in the assigns' do
    do_post
    assigns(:gift).should.not.be.nil
    assigns(:gift_mail).should.not.be.nil
  end

  specify 'should use dt/gifts/preview template' do
    do_post
    template.should.be 'dt/gifts/preview'
  end
  
  private
  def do_post(options={})
    gift_params = { 
      :project_id => 1, 
      :amount => 100.00, 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!',
      }
    
    # merge with passed options
    gift_params.merge!(options[:gift]) if options[:gift] != nil
    options.delete(:gift) if options[:gift] != nil
    
    post :preview, { :gift => gift_params }.merge(options)
  end
end

context "Dt::Gifts confirm behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should show confirm template on a post with login" do
    do_post
    template.should.be "dt/gifts/confirm"
  end

  specify "should show confirm template on a post without login" do
    do_post( {}, false )
    template.should.be "dt/gifts/confirm"
  end

  specify "form should post to create action" do
    do_post
    assert_select "form[method=post][action=/dt/gifts]#giftform"
  end

  specify "form output should always contain amount, name, email, to_name, to_email, comments, credit_card, card_expiry, first_name, last_name, address, city, province, postal_code, country fields" do
    inputs = %w( input#gift_amount input#gift_name input#gift_email input#gift_to_name input#gift_to_email input#gift_message input#gift_send_at
                 input#gift_credit_card input#gift_card_expiry input#gift_first_name input#gift_last_name 
                 input#gift_address input#gift_city input#gift_province input#gift_postal_code input#gift_country )
    # !logged_in?
    do_post
    assert_select "#giftform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
    # logged_in?
    do_post( {}, false )
    assert_select "#giftform" do
      inputs.each do |selector|
        assert_select selector
      end
    end
  end

  specify "form output should include project_id field when params[:project_id] is passed" do
    do_post( :project_id => 1 )
    assert_select "#giftform input[type=hidden]#gift_project_id"
  end

  specify "form should use new template if we don't include to_email, email, amount" do
    gift_params = {}
    fields = %w( to_email email amount ).each {|f| 
      do_post({ :gift => {f.to_sym => nil} })
      template.should.be 'dt/gifts/new'
    }
  end

  specify "form should use new template if we are paying by credit card but don't include first_name, last_name, address, city, province, postal_code, country, expiry_month, expiry_year" do
    fields = %w( first_name last_name address city province postal_code country expiry_month expiry_year ).each {|f|
      do_post({ :gift => { :credit_card => '4111111111111111', f.to_sym => nil }}, true, true )
      template.should.be 'dt/gifts/new'
    }
  end

  protected
  def do_post(options={}, login = true, credit = true)
    login_as :quentin if login == true
    credit = true if login == false
    gift_params = { 
      :project_id => 1, 
      :amount => 100.00, 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!',
      }
    if credit == true
      gift_params.merge!( {
        :first_name => 'Timothy', 
        :last_name => 'Glen', 
        :address => '36 Hill Trail', 
        :city => 'Guelph', 
        :province => 'ON', 
        :postal_code => 'N1E 7C5', 
        :country => 'Canada', 
        :credit_card => 4111111111111111, 
        :expiry_month => '04', 
        :expiry_year => '09'
        } )
    end
    gift_params[:user_id] = users(:quentin).id if login == true
    
    # merge with passed options
    gift_params.merge!(options[:gift]) if options[:gift] != nil
    options.delete(:gift) if options[:gift] != nil
    
    post :confirm, { :gift => gift_params}.merge(options)
  end
end

context "Dt::Gifts create behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should create a gift and render the create template" do
    # !logged_in?
    lambda {
      create_gift(nil, false)
      template.should.be "dt/gifts/create"
    }.should.change(Gift, :count)
    # logged_in?
    lambda {
      create_gift()
      template.should.be "dt/gifts/create"
    }.should.change(Gift, :count)
  end

  specify "@gift should be assigned on create" do
    create_gift()
    assigns(:gift).should.not.be.nil
  end
  
  specify "@gift should contain an authorization_result when a credit_card is used" do
    create_gift(nil, false)
    assigns(:gift).authorization_result.should.not.be nil
  end

  protected
  def create_gift(options={}, login = true, credit = true)
    login_as :quentin if login == true
    credit = true if login == false
    gift_params = { 
      :amount => 100.00, 
      :name => 'Tim Glen', 
      :email => 'timglen@pivotib.com', 
      :to_name => 'Curtis', 
      :to_email => 'curtis@pivotib.com', 
      :message => 'Hello World!'
      }
    if credit == true
      gift_params.merge!( {
        :first_name => 'Timothy', 
        :last_name => 'Glen', 
        :address => '36 Hill Trail', 
        :city => 'Guelph', 
        :province => 'ON', 
        :postal_code => 'N1E 7C5', 
        :country => 'Canada', 
        :credit_card => 4111111111111111, 
        :expiry_month => '04', 
        :expiry_year => '09'
        } )
    end
    gift_params[:user_id] = users(:quentin).id if login == true
    
    # merge with passed options
    gift_params.merge!(options) if options != nil
    
    post :create, { :gift => gift_params }
  end
end

context "Dt::Gifts open behaviour" do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users, :projects
  include DtAuthenticatedTestHelper

  specify "if no pickup_code is passed, show a basic pickup form" do
    get :open
    assert_select "form[method=get][action=/dt/gifts;open]#giftform"
    assert_select "form[method=get][action=/dt/gifts;open]#giftform" do
      assert_select "input[type=text]#code"
    end
  end

  specify "if an invalid pickup_code is passed, show the open template again" do
    get :open, :code => 'notcorrect'
    template.should.be 'dt/gifts/open'
  end

  specify "if a valid pickup_code is passed show the gift with links to login/signup" do
    get :open, :code => 'nqlut05m74jp'
    assert_select "div#login-signup"
  end

  specify "if logged_in? and a valid pickup_code is passed show the gift with an unwrap form" do
    login_as :quentin
    get :open, :code => 'r4tyfgo0xt7v'
    assert_select "form[method=post][action=/dt/gifts/#{assigns(:gift).id};unwrap]#giftform" do
      assert_select "input[type=hidden][name=_method][value=put]"
      assert_select "input[type=hidden][value=r4tyfgo0xt7v]"
      assert_select "input[type=submit]"
    end
  end
end

context "Dt::Gifts unwrap behaviour" do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users, :projects
  include DtAuthenticatedTestHelper
  
  specify "should get redirected if not logged_in?" do
    unwrap_gift
    should.redirect dt_login_path
  end

  specify "should get redirected if no gift pickup_code is passed" do
    login_as :quentin
    unwrap_gift(:pickup_code => nil)
    should.redirect :action => 'open'
    unwrap_gift(:pickup_code => "")
    should.redirect :action => 'open'
  end

  specify "should remove the pickup_code and set picked_up_at to Time.now" do
    login_as :quentin
    now = Time.now.utc
    unwrap_gift
    assigns(:gift).pickup_code.should.be.nil
    assigns(:gift).picked_up_at.to_s.should.equal now.to_s
  end

  specify "should create a deposit and put the gift into my account" do
    login_as :quentin
    lambda {
      unwrap_gift
    }.should.change(Deposit, :count)
  end

  specify "if the gift includes a project_id, should still create a deposit" do
    login_as :quentin
    lambda {
      unwrap_gift(:id => 3)
    }.should.change(Deposit, :count)
  end

  specify "if the gift includes a project_id, should also create a investment" do
    login_as :quentin
    lambda {
      unwrap_gift({ :pickup_code => 'nqlut05m74jp' }, 3) #pickup_code is for fixture with id of 3
    }.should.change(Investment, :count)
  end

  specify "should create a UserTransaction" do
    login_as :quentin
    lambda {
      unwrap_gift
    }.should.change(UserTransaction, :count)
  end

  specify "should redirect to my account overview" do
    login_as :quentin
    unwrap_gift
    should.redirect :controller => 'dt/accounts', :action => 'show', :id => users(:quentin).id
  end
  
  private 
  def unwrap_gift(options = {}, id = 2)
    put :unwrap, :id => id, :gift => { :pickup_code => "r4tyfgo0xt7v" }.merge(options)
  end
end

context "Dt::Gifts show, edit, update and destroy should not exist" do
  use_controller Dt::GiftsController
  specify "method should not exist" do
    %w( show edit update destroy ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end


# As any gift giver, I should:
#   - be able to choose an ecard
# 
# When confirming my gift, I should:
#   - be able to preview my card
# 
# Having completed the gift giving process, I should:
#   - be offered a printable card (with the same image) upon completion
# 
# As a gift receiver I should:
#   - be notified receiver email that money has been given to them - email must contain a "gift code"
#   - 7 days before expiry, if the gift is unclaimed send an email to the giver and receiver letting them know
#   - 2 days before expiry, if the gift is unclaimed send an email to the giver and receiver letting them know
#   - 1 day before expiry, if the gift is unclaimed send an email to the giver and receiver letting them know
#   - upon expiry, the money is allocated directly to the highest priority project
