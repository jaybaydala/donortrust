require File.dirname(__FILE__) + '/../../test_helper'

context "User" do
  include DtAuthenticatedTestHelper
  fixtures :users, :memberships, :groups
  
  setup do
  end

  specify "should create a user" do
    lambda {
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    }.should.change(User, :count)
  end

  specify "should require login" do
    lambda {
      u = create_user(:login => nil)
      u.errors.on(:login).should.not.be.nil
    }.should.not.change(User, :count)
  end
  
  specify "should require password" do
    lambda {
      u = create_user(:password => nil)
      u.errors.on(:password).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "should require password confirmation" do
    lambda {
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "should require either (first_name & last_name) or display_name" do
    lambda {
      u = create_user(:first_name => nil, :last_name => nil, :display_name => nil)
      u.errors.on(:first_name).should.not.be.nil
    }.should.not.change(User, :count)
  end
  
  specify "if terms_of_use is not nil, the value must be '1'" do
    lambda {
      u = create_user(:terms_of_use => 0)
      u.errors.on(:terms_of_use).should.not.be.nil
    }.should.not.change(User, :count)
    lambda {
      u = create_user(:terms_of_use => '1')
      u.errors.on(:terms_of_use).should.be.nil
    }.should.change(User, :count)
  end

  specify "should require valid email as login" do
    lambda {
      u = create_user(:login => 'timglen')
      create_user(:login => 'timglen@pivotib')
      
      u = create_user(:login => '@pivotib.com')
      u.errors.on(:login).should.not.be.nil
      
      u = create_user(:login => 'pivotib.com')
      u.errors.on(:login).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "should add an activation_code upon create" do
    user = create_user
    user.activation_code.should.not.be.nil
  end

  specify "should return the same thing for login and email" do
    u = users(:quentin)
    u.login.should.be u.email
  end
  
  specify "login_changed? should be true if the login changes" do
    u = users(:quentin)
    u.update_attributes(:login => 'quentin2@example.com')
    u.should.login_changed
  end

  specify "login_changed? should be false if the login doesn't change" do
    u = users(:quentin)
    u.update_attributes(:login => 'quentin@example.com')
    u.should.not.login_changed
  end

  specify "should reset password" do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    users(:quentin).should.equal User.authenticate('quentin@example.com', 'new password')
  end

  specify "should not rehash password" do
    users(:quentin).update_attributes(:first_name => 'Q')
    users(:quentin).should.equal User.authenticate('quentin@example.com', 'test')
  end

  specify "should set remember token" do
    users(:quentin).remember_me
    users(:quentin).remember_token.should.not.be.nil
    users(:quentin).remember_token_expires_at.should.not.be.nil
  end

  specify "should unset remember token" do
    users(:quentin).remember_me
    users(:quentin).remember_token.should.not.be.nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should.be.nil
  end

  specify "should return 'first_name last_initial' if display_name is empty" do
    u = users(:quentin)
    u.name.should.equal "#{u.first_name} #{u.last_name[0,1]}."
  end

  specify "full_name should return 'first_name last_name'" do
    u = users(:quentin)
    u.full_name.should.equal "#{u.first_name} #{u.last_name}"
  end

  specify "should return 'display_name' if display_name is not empty" do
    u = users(:tim)
    u.name.should.equal "#{u.display_name}"
  end
  
  specify "group_admin? should return whether the user is the admin of any group" do
    u = users(:quentin)
    u.group_admin?.should.be true
    # make tim a general member for all groups...
    u = users(:tim)
    u.memberships.each do |m|
      m.membership_type = Membership.member
      m.save
    end
    u.group_admin?.should.be false
  end

  private
  def create_user(options = {})
    User.create({ :login => 'quire@example.com', :first_name => 'quire', :last_name => 'test', :display_name => 'quirename', :password => 'quire', :password_confirmation => 'quire', :terms_of_use => '1', :country => "Canada" }.merge(options))
  end
end

context "User under 13" do
  include DtAuthenticatedTestHelper
  fixtures :users
  
  setup do
  end
  
  specify "An under 13 user cannot their first name, last_name, address, city, province, postal_code or country" do
    %w( first_name last_name address city province postal_code country ).each do |field|
      lambda {
        u = create_user(field.to_sym => 'Foo')
        u.errors.on(field.to_sym).should.not.be.nil
      }.should.not.change(User, :count)
    end
  end

  specify "full_name should return 'display_name'" do
    u = create_user
    u.full_name.should.equal u.display_name
  end
  
  private
  def create_user(options = {})
    User.create({ :under_thirteen => true, :login => 'parents_email@example.com', :display_name => 'tester', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end

context "User Account" do
  include DtAuthenticatedTestHelper
  fixtures :users

  specify "should get deposits balance" do
    u = User.find(users(:quentin).id)
    u.deposited.should.not.be.nil
  end

  specify "should get investments balance" do
    u = User.find(users(:quentin).id)
    u.invested.should.not.be.nil
  end

  specify "should get gifts balance" do
    u = User.find(users(:quentin).id)
    u.gifted.should.not.be.nil
  end

  specify "should get an account balance" do
    u = User.find(users(:quentin).id)
    u.balance.should.not.be.nil
  end

  specify "balance should equal (deposited - invested - gifted(true))" do
    u = User.find(users(:quentin).id)
    u.balance.should.equal u.deposited - u.invested - u.gifted(true)
  end
end


context "UserAuthentication" do
  include DtAuthenticatedTestHelper
  fixtures :users
  
  specify "should authenticate user" do
    users(:quentin).should.equal User.authenticate('quentin@example.com', 'test')
  end

  specify "should authenticate user who has never logged in" do
    u = User.find(users(:quentin).id)
    u.update_attributes( :last_logged_in_at => nil )
    User.authenticate('quentin@example.com', 'test').should.not.be.nil
  end

  specify "expired? should only return true if they haven't logged in for more than a year" do
    u = User.find(users(:quentin).id)
    u.update_attributes( :last_logged_in_at => Time.now + 1.second )
    u.expired?.should.be false
    u.update_attributes( :last_logged_in_at => Time.now - 1.second - 1.year ) # 1 year plus 1 second ago
    u.expired?.should.be true
  end

  specify "should not authenticate user who hasn't logged in for more than a year" do
    u = User.find(users(:quentin).id)
    u.update_attributes( :last_logged_in_at => Time.now + 1.second )
    User.authenticate('quentin@example.com', 'test').should.not.be.nil
    u.update_attributes( :last_logged_in_at => Time.now - 1.second - 1.year ) # 1 year plus 1 second ago
    User.authenticate('quentin@example.com', 'test').should.be.nil
  end

  specify "authenticate should an activated user account where activated_at IS NOT NULL" do
    User.authenticate('quentin@example.com', 'test').should.not.be nil
  end

  specify "authenticate should not return a user account where activated_at IS NULL" do
    User.authenticate('aaron@example.com', 'test').should.be nil
  end
end

context "UserActivation" do
  include DtAuthenticatedTestHelper
  fixtures :users
  
  setup do
  end

  specify "activate should nullify activation_code and set activated_at to now" do
    @user = User.find_by_login('aaron@example.com')
    @user.activation_code.should.not.be nil
    @user.activated_at.should.be nil
    @user.activate
    @user.activation_code.should.be nil
    @user.activated_at.should.not.be nil
  end
  
end

