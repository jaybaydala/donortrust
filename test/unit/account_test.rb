require File.dirname(__FILE__) + '/../test_helper'

#class BusAdmin::AccountTest < Test::Unit::TestCase
context "Accounts" do
  
  fixtures :accounts

  def setup
    @fixture_account = Account.find(:first)
  end
  
  specify "The acount should have a first name and last name" do
    @fixture_account.first_name.should.not.be.nil
    @fixture_account.last_name.should.not.be.nil
  end
  
  specify "nil name should not validate" do
    @fixture_account.first_name = nil
    @fixture_account.should.not.validate
  end
  
  specify "email must be valid" do
    @fixture_account.email = "bob"
    @fixture_account.should.not.validate
  end
  specify "email must have '@' to be valid" do
    @fixture_account.email = "bob.bob.com"
    @fixture_account.should.not.validate
  end
  specify "email must have '.' after '@' to be valid" do
    @fixture_account.email = "bob.bob@com"
    @fixture_account.should.not.validate
  end
  specify "valid email should validate" do
    @fixture_account.email = "bob.bob@bob.com"
    @fixture_account.should.validate
  end
  
  
end
