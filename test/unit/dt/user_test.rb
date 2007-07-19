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
      assert u.errors.on(:login)
    }.should.not.change(User, :count)
  end
  
  specify "should require password" do
    lambda {
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    }.should.not.change(User, :count)
  end

  specify "should require password confirmation" do
    lambda {
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    }.should.not.change(User, :count)
  end

  specify "should require email" do
    lambda {
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    }.should.not.change(User, :count)
  end

  specify "should require valid email" do
    lambda {
      u = create_user(:email => 'timglen')
      create_user(:email => 'timglen@pivotib')
      
      u = create_user(:email => '@pivotib.com')
      assert u.errors.on(:email)
      
      u = create_user(:email => 'pivotib.com')
      assert u.errors.on(:email)
    }.should.not.change(User, :count)
  end

  specify "should reset password" do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    users(:quentin).should.equal User.authenticate('quentin', 'new password')
  end

  specify "should not rehash password" do
    users(:quentin).update_attributes(:login => 'quentin2')
    users(:quentin).should.equal User.authenticate('quentin2', 'test')
  end

  specify "should authenticate user" do
    users(:quentin).should.equal User.authenticate('quentin', 'test')
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

  private
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end
