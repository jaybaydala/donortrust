require File.dirname(__FILE__) + '/../test_helper'

context "Bus User Type Tests " do
  fixtures :bus_user_types
 
  specify "should create a bus user type" do
      BusUserType.should.differ(:count).by(1) {create_bus_user_type} 
    end
     
   specify "should require name" do
    lambda {
      t = create_bus_user_type(:name => nil)
      t.errors.on(:name).should.not.be.nil
      }.should.not.change(BusUserType, :count)
   end    
    
  def create_bus_user_type(options = {})
    BusUserType.create({ :name => 'test type' }.merge(options))                                                                                                                                                                                                                                                                                                                                             
  end                                                          
end
