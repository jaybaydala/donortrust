require File.dirname(__FILE__) + '/../test_helper'


context "User Tests " do
  fixtures :users

  specify "should create a user" do
   User.should.differ(:count).by(1) {create_user} 
  end

  specify "login should be valid email" do
    lambda {
      t = create_user(:login => 'one@here.ca')
      t.errors.on(:login).should.be.nil
      t = create_user(:login => 'one')
      t.errors.on(:login).should.not.be.nil
    }.should.change(User, :count)
  end

   specify "login should unique" do
    lambda {
      t = create_user(:login => 'one@here.ca')
      t.errors.on(:login).should.be.nil
      t = create_user(:login => 'one@here.ca')
      t.errors.on(:login).should.not.be.nil
    }.should.change(User, :count)
  end

  specify "password should be less then 40 Characters" do
    lambda {
      t = create_user(:password=> 'This will enter more then one 40 characters into the column.')
      t.errors.on(:password).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "password should be min of 4 Characters" do
    lambda {
      t = create_user(:password=> 'aaa')
      t.errors.on(:password).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "login should be less then 100 Characters" do
    lambda {
      t = create_user(:login=> 'This will enter more then 100 characters into the column. This will enter more then 100 characters into the column.')
      t.errors.on(:login).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "login should be min of 3 Characters" do
    lambda {
      t = create_user(:login=> 'aa')
      t.errors.on(:login).should.not.be.nil
    }.should.not.change(User, :count)
  end

  specify "should require login" do
    lambda {
      t = create_user(:login => nil)
      t.errors.on(:login).should.not.be.nil
    }.should.not.change(User, :count)
  end
  
  #MP
  specify "should require country if NOT under thirteen" do
    t = create_user(:country => nil, :under_thirteen => 0)
    t.errors.on(:country).should.not.be.nil
  end
  
  #MP
  specify "should NOT require country if under thirteen" do
    t = create_user(:country => nil, :under_thirteen => 1)
    t.errors.on(:country).should.be.nil
  end
  
  #MP
  specify "should return true if in specified country" do
    t = create_user({:country => 'Canada'})
    t.in_country?('Canada').should.equal true
  end
  
  #MP
  specify "should return false if not in specified country" do
    t = create_user({:country => 'blah'})
    t.in_country?('Canada').should.equal false
  end
  
  #MP
  specify "should return false if users country is nil" do
    t = create_user({:country => nil})
    t.in_country?('Canada').should.equal false
  end
  
  #MP
  specify "should return false if specified country is nil" do
    t = create_user({:country => 'Canada'})
    t.in_country?(nil).should.equal false
  end

  def create_user(options = {})
    User.create({ :login => 'Login@test.ca', :first_name => 'FirstName', :last_name => 'LastName', :display_name => 'DisplayName', :address => '4320 15 st', :city => 'Calgary', :province => 'Alberta', :country => 'Canada', :postal_code => 'T2T4B2', :under_thirteen => 0, :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1', :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :created_at => '2006-10-16 13:14:40', :updated_at => '2007-10-16 13:14:40', :remember_token => 'test', :remember_token_expires_at => '2011-10-16 13:14:40', :activation_code => 'code', :activated_at => '2007-10-16 13:14:40', :last_logged_in_at => '2007-09-16 13:14:40' }.merge(options))  
  #       User.create({ :login => 'Login@th', :first_name => 'FirstName', :last_name => 'LastName' }.merge(options))#, :display_name => 'DisplayName', :address => '4320 15 st', :city => 'Calgary', :province => 'Alberta', :postal_code => 'T2T4B2', :country => 'CA', :under_thirteen => 0, :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1', :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :created_at => '2006-10-16 13:14:40', :updated_at => '2007-10-16 13:14:40', :remember_token => 'test', :remember_token_expires_at => '2011-10-16 13:14:40', :activation_code => 'code', :activated_at => '2007-10-16 13:14:40', :last_logged_in_at => '2007-09-16 13:14:40' }.merge(options))  
  end                                                          
end
