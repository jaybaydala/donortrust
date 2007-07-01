require File.dirname(__FILE__) + '/../test_helper'

context "Targets" do
  fixtures :targets

setup do
    @target = Target.find(1)
  end
 
  specify "The target should have a millennium goal id and & description" do
    @target.millennium_development_goal_id.should.not.be.nil
    @target.description.should.not.be.nil
  end

specify "duplicate name should not validate" do
    @target1 = Target.new( :millennium_development_goal_id => 1, :description =>  @target.description)
    
    @target1.should.not.validate
    
end
specify "nil millennium_goal_id should not validate" do
    @target.millennium_development_goal_id = nil
    @target.should.not.validate
  end
  
  specify "nil description should not validate" do
    @target.description = nil
    @target.should.not.validate
  end

end