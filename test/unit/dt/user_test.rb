require File.dirname(__FILE__) + '/../../test_helper'

context "User" do
  include DtAuthenticatedTestHelper
  fixtures :users
  
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

  specify "should authenticate user" do
    users(:quentin).should.equal User.authenticate('quentin@example.com', 'test')
  end

  specify "should authenticate user who has never logged in" do
    u = User.find(users(:quentin).id)
    u.update_attributes( :last_logged_in_at => nil )
    User.authenticate('quentin@example.com', 'test').should.not.be.nil
  end

  specify "should not authenticate user who hasn't logged in for more than a year" do
    u = User.find(users(:quentin).id)
    u.update_attributes( :last_logged_in_at => Time.now.last_year )
    User.authenticate('quentin@example.com', 'test').should.not.be.nil
    u.update_attributes( :last_logged_in_at => Time.now.ago((3600 * 24 * 365) + 1) ) # 1 year plus 1 second ago
    User.authenticate('quentin@example.com', 'test').should.be.nil
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

  private
  def create_user(options = {})
    User.create({ :login => 'quire@example.com', :first_name => 'quire', :last_name => 'test', :display_name => 'quirename', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end

context "UserAuthentication" do
  include DtAuthenticatedTestHelper
  fixtures :users
  
  setup do
  end

  specify "authenticate should an activated user account where activated_at IS NOT NULL" do
    User.authenticate('quentin@example.com', 'test').should.not.be nil
  end

  specify "authenticate should not return a user account where activated_at IS NULL" do
    User.authenticate('aaron@example.com', 'test').should.be nil
  end

  specify "authenticate should not return a user account where activated_at IS NULL if we set check_activated to false" do
    User.authenticate('aaron@example.com', 'test', false).should.not.be nil
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
    @user.activate.should.be true
    @user.activation_code.should.be nil
    @user.activated_at.should.not.be nil
  end
  
end

