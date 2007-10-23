require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::KeyMeasureTest < Test::Unit::TestCase
  fixtures :projects, :measures, :key_measure_datas, :key_measures, :millennium_goals, :targets

  context "Key Measure Tests " do
    
    specify "should create a key measure" do
      KeyMeasure.should.differ(:count).by(1) {create_key_measure}
    end     
 
    specify "should require project_id" do
      lambda {
        t = create_key_measure(:project_id => nil)
        t.errors.on(:project_id).should.not.be.nil
      }.should.not.change(KeyMeasure, :count)
    end
    
    specify "should require measure_id" do
      lambda {
        t = create_key_measure(:measure_id => nil)
        t.errors.on(:measure_id).should.not.be.nil
      }.should.not.change(KeyMeasure, :count)
    end
   
    def create_key_measure(options = {})
      KeyMeasure.create({ :project_id => 1, :measure_id => 1, :target => 1, :millennium_goal_id => 1 }.merge(options))  
    end                                                          
  end
end
