require File.dirname(__FILE__) + '/../test_helper'

class BusAccountTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :bus_accounts

  def test_should_create_bus_account
    assert_difference BusAccount, :count do
      bus_account = create_bus_account
      assert !bus_account.new_record?, "#{bus_account.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference BusAccount, :count do
      u = create_bus_account(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference BusAccount, :count do
      u = create_bus_account(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference BusAccount, :count do
      u = create_bus_account(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference BusAccount, :count do
      u = create_bus_account(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    bus_accounts(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal bus_accounts(:quentin), BusAccount.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    bus_accounts(:quentin).update_attributes(:login => 'quentin2')
    assert_equal bus_accounts(:quentin), BusAccount.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_bus_account
    assert_equal bus_accounts(:quentin), BusAccount.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    bus_accounts(:quentin).remember_me
    assert_not_nil bus_accounts(:quentin).remember_token
    assert_not_nil bus_accounts(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    bus_accounts(:quentin).remember_me
    assert_not_nil bus_accounts(:quentin).remember_token
    bus_accounts(:quentin).forget_me
    assert_nil bus_accounts(:quentin).remember_token
  end

  protected
    def create_bus_account(options = {})
      BusAccount.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
