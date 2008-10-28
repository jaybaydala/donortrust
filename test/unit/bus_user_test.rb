require File.dirname(__FILE__) + '/../test_helper'


context "Bus Users Tests " do
  fixtures :bus_users

  specify "should create a bus user" do
    BusUser.should.differ(:count).by(1) {create_bus_user} 
  end
     
  specify "should require login" do
    lambda {
      t = create_bus_user(:login => nil)
      t.errors.on(:login).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end
   
  specify "should require email" do
    lambda {
      t = create_bus_user(:email => nil)
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end
  
#    specify "should require bus user type id" do
#      lambda {
#        t = create_bus_user(:bus_user_type_id => nil)
#        t.errors.on(:bus_user_type_id).should.not.be.nil
#      }.should.not.change(BusUser, :count)
#    end    
  
  specify "password should be less then 40 Characters" do
    lambda {
      t = create_bus_user(:password=> 'This will enter more then one 40 characters into the column.')
      t.errors.on(:password).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end
  
  specify "password should be min of 4 Characters" do
    lambda {
      t = create_bus_user(:password=> 'aaa')
      t.errors.on(:password).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end

  specify "login should be less then 40 Characters" do
    lambda {
      t = create_bus_user(:login=> 'This will enter more then 40 characters into the column.')
      t.errors.on(:login).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end
  
  specify "login should be min of 3 Characters" do
    lambda {
      t = create_bus_user(:login=> 'aa')
      t.errors.on(:login).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end

  specify "email should be less then 100 Characters" do
    lambda {
      t = create_bus_user(:email=> 'This will enter more then 100 characters into the column. This will enter more then 100 characters into the column.')
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end   
  
  specify "email should be min of 3 Characters" do
    lambda {
      t = create_bus_user(:email=> 'aa')
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(BusUser, :count)
  end
  
  specify "login should be unique" do
    @bus_user = create_bus_user()
    @bus_user.save
    @bus_user = create_bus_user()
    @bus_user.should.not.validate
  end   
  
  specify "email should be unique" do
    @bus_user = create_bus_user()
    @bus_user.save
    @bus_user = create_bus_user()
    @bus_user.should.not.validate
  end      
   
  def create_bus_user(options = {})
    BusUser.create({ :login => 'testuser', :email => 'test@test.ca', :crypted_password => '8259e05250c15e247fc7ec614fe39a4990442ad7', :salt => '0f2ddf950f9c021b1c4ba49f6140796576427e3c', :created_at => '2007-08-04 01:33:22', :updated_at => '2007-08-04 02:13:16', :remember_token => 'test token', :remember_token_expires_at => '2009-08-04 02:13:16', :bus_user_type_id => '1' }.merge(options))  
  end                                                          
end