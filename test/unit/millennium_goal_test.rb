require File.dirname(__FILE__) + '/../test_helper'

context "MillenniumGoals" do
  fixtures :millennium_goals
   
    specify "should create a millennium goal" do
      MillenniumGoal.should.differ(:count).by(1) { create_millennium } 
    end
    
    specify "should require name" do
      lambda {
        t = create_millennium(:name => nil)
        t.errors.on(:name).should.not.be.nil
      }.should.not.change(MillenniumGoal, :count)
    end
   
#    specify "should require description" do
#      lambda {
#        t = create_millennium(:description => nil)
#        t.errors.on(:description).should.not.be.nil
#      }.should.not.change(MillenniumGoal, :count)
#    end
    
    specify "duplicate name should not validate" do
      @goal = create_millennium()
      @goal.save
      @goal = create_millennium()
      @goal.should.not.validate
    end   
   
    def create_millennium(options = {})
      MillenniumGoal.create({ :name => 'Test Name', :description => 'My Description' }.merge(options))  
    end 
  end
