require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::RankTest < Test::Unit::TestCase
  fixtures :rank, :rank_type
  
  context "Rank Tests " do
   
    specify "should create a rank" do
      Rank.should.differ(:count).by(1) {create_rank} 
    end
    
     specify "should require rank_value" do
      lambda {
        t = create_rank(:rank_value_id => nil)
        t.errors.on(:rank_value_id).should.not.be.nil
      }.should.not.change(Rank, :count)
   end
    
    specify "should require rank_type" do
      lambda {
        t = create_rank(:rank_type_id => nil)
        t.errors.on(:rank_type_id).should.not.be.nil
      }.should.not.change(Rank, :count)
   end
     
    def create_rank(options = {})
      Rank.create({ :rank_value_id => 1, :rank_type_id => 1, :project_id => 1 }.merge(options))  
    end                                                          
  end
end
