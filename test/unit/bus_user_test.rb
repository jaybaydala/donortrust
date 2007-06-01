require File.dirname(__FILE__) + '/../test_helper'

class BusUserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :bus_users

  def test_should_create_bus_user
    assert_difference BusUser, :count do
      bus_user = create_bus_user
      assert !bus_user.new_record?, "#{bus_user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference BusUser, :count do
      u = create_bus_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference BusUser, :count do
      u = create_bus_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference BusUser, :count do
      u = create_bus_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference BusUser, :count do
      u = create_bus_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    bus_users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal bus_users(:quentin), BusUser.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    bus_users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal bus_users(:quentin), BusUser.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_bus_user
    assert_equal bus_users(:quentin), BusUser.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    bus_users(:quentin).remember_me
    assert_not_nil bus_users(:quentin).remember_token
    assert_not_nil bus_users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    bus_users(:quentin).remember_me
    assert_not_nil bus_users(:quentin).remember_token
    bus_users(:quentin).forget_me
    assert_nil bus_users(:quentin).remember_token
  end

  protected
    def create_bus_user(options = {})
      BusUser.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
