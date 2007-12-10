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

context "Dt::Gifts show behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :user_transactions, :users, :e_cards
  include DtAuthenticatedTestHelper


  specify "should return a pdf for a valid id" do
    @gift = create_gift
    get :show, :id => @gift.id
    should.not.redirect
    @response.headers["Content-Type"].should.equal "application/pdf"
  end

  specify "should redirect for gift that's already been picked up" do
    @gift = create_gift
    @gift.pickup
    get :show, :id => @gift.id
    should.redirect
    flash[:notice].should =~ /^The gift has already been picked up/
  end

  specify "should redirect for an invalid id" do
    get :show, :id => 9999999999999
    should.redirect
    flash[:notice].should == "That gift does not exist"
  end
  
  def create_gift
    @gift = Gift.create(:e_card_id => 1, :user_id => 1, :amount => 10, :email => 'test@example.com', :to_email => 'test2@example.com')
  end
end

context "Dt::Gifts new behaviour"do
  use_controller Dt::GiftsController
  fixtures :gifts, :e_cards, :user_transactions, :users, :projects
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

  specify "should assign @ecards" do
    get :new
    assigns(:ecards).class.should.be Array
    assigns(:ecards).each do |ecard|
      ecard.class.should.be ECard
    end
  end

  specify "form output should always contain amount, to_name, to_email, credit_card, card_expiry fields, comments" do
    # !logged_in?
    get :new
    inputs = %w( input#gift_amount input#gift_name input#gift_email input#gift_email_confirmation input#gift_to_name 
                 input#gift_to_email input#gift_to_email_confirmation textarea#gift_message 
                 select#gift_send_at_1i select#gift_send_at_2i select#gift_send_at_3i select#gift_send_at_4i select#gift_send_at_5i 
                 input#gift_credit_card select#gift_expiry_month select#gift_expiry_year input#gift_first_name input#gift_last_name 
                 input#gift_address input#gift_city input#gift_province input#gift_postal_code select#gift_country )
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
    fields = %w( first_name last_name address city province postal_code email )
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
    #page.should.select "#giftform #credit_payment"
    page.should.select "#giftform #account_payment"
  end

  specify "if project_id is passed, should show the project" do
    @project = Project.find_public(:first)
    @project.update_attributes(:project_status_id => 2)
    get :new, :project_id => @project.id
    page.should.select "#giftform input[type=radio]#gift_project_id_#{@project.id}"
  end

  specify "if project_id is not passed, should suggest giving a project" do
    get :new
    page.should.select "#giftform #projectsuggest a[href=/dt/projects]"
  end
  
  specify "should contain a preview submit button" do
    get :new
    page.should.select "#ecardPreview"
  end

  specify "should redirect if !project.fundable?" do
    login_as :quentin
    @project = Project.find_public(:first)
    @project.update_attributes(:project_status_id => 4) #makes it non-fundable
    get :new, :project_id => @project
    should.redirect dt_project_path(@project.id)
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
  fixtures :gifts, :e_cards, :user_transactions, :users, :projects
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
  
  specify "should trim mailto: from the start of to_email and email fields" do
    do_post( :gift => {:to_email => 'mailto: curtis@example.com', :email => 'mailto:  tim@example.com'} )
    gift = assigns(:gift)
    gift[:to_email].should == 'curtis@example.com'
    gift[:email].should == 'tim@example.com'
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
  
  specify "a TaxReceipt should be created if credit_card is used with Canada as country" do
    # not logged in
    lambda {
      create_gift({}, false)
    }.should.change(TaxReceipt, :count)
    # logged in
    lambda {
      create_gift()
    }.should.change(TaxReceipt, :count)
  end

  specify "a TaxReceipt should not be created if credit_card is used without a country other than Canada" do
    # not logged in
    lambda {
      create_gift({:country => 'United States of America'}, false)
    }.should.not.change(TaxReceipt, :count)
    # logged in
    lambda {
      create_gift(:country => 'United States of America')
    }.should.not.change(TaxReceipt, :count)
  end
  
  specify "3 emails should be sent on gift creation if a credit card is used - tax receipt, gift confirm and gift email" do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    
    @emails.clear
    create_gift({}, false, true)
    @emails.length.should.equal 3
    
    @emails.clear
    create_gift()
    @emails.length.should.equal 3
  end

  specify "2 emails should be sent on gift creation if a credit card is not used - gift confirm and gift email" do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    
    @emails.clear
    create_gift({}, true, false)
    @emails.length.should.equal 2
  end

  specify "2 emails should be sent on gift creation if a country is not Canada - gift confirm and gift email" do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    
    @emails.clear
    create_gift({:country => 'United States of America'}, true, false)
    @emails.length.should.equal 2
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
      :message => 'Hello World!', 
      :e_card_id => 1
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
    %w( edit update destroy ).each do |m|
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
