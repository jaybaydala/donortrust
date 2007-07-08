require File.dirname(__FILE__) + '/../test_helper'
context "MillenniumGoals" do
  fixtures :millennium_goals

setup do
    @MillenniumGoal = MillenniumGoal.find(1)
  end
 
  specify "The Millennium Goal should have a description" do
    @MillenniumGoal.description.should.not.be.nil
  end

specify "duplicate description should not validate" do
    @MillenniumGoal = MillenniumGoal.new( :description =>  @MillenniumGoal.description )
    @MillenniumGoal.should.not.validate
    
end

  
  specify "nil description should not validate" do
    @MillenniumGoal.description = nil
    @MillenniumGoal.should.not.validate
  end
end
