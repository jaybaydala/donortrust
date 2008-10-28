require File.dirname(__FILE__) + '/../test_helper'


context "Bus Security Level Tests " do
  fixtures :bus_security_levels
 
  specify "should create a bus security level" do
    BusSecurityLevel.should.differ(:count).by(1) {create_bus_security_level} 
  end
     
  specify "should require controller" do
    lambda {
      t = create_bus_security_level(:controller => nil)
      t.errors.on(:controller).should.not.be.nil
    }.should.not.change(BusSecurityLevel, :count)
  end
   
  def create_bus_security_level(options = {})
    BusSecurityLevel.create({ :controller => 'bus_admin/home' }.merge(options))
  end                                                          
end
