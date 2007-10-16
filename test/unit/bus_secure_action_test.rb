require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::BusSecureActionTest < Test::Unit::TestCase
  fixtures :bus_secure_actions

  context "Bus Secure Action Tests " do
     
    specify "should create a bus secure action" do
      BusSecureAction.should.differ(:count).by(1) {create_secure_action} 
    end
       
    specify "should require permitted actions" do
      lambda {
        t = create_secure_action(:permitted_actions => nil)
        t.errors.on(:permitted_actions).should.not.be.nil
      }.should.not.change(BusSecureAction, :count)
    end
    
    specify "should require bus security level id" do
      lambda {
        t = create_secure_action(:bus_security_level_id => nil)
        t.errors.on(:bus_security_level_id).should.not.be.nil
      }.should.not.change(BusSecureAction, :count)
    end
     
    def create_secure_action(options = {})
      BusSecureAction.create({ :permitted_actions => 'test',  :bus_security_level_id => 1 }.merge(options))                           
    end                                                          
  end
end
