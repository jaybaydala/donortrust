require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::RankTest < Test::Unit::TestCase
  fixtures :ranks
  
  context "Rank Tests " do
   
    specify "should create a rank" do
      Rank.should.differ(:count).by(1) {create_rank} 
    end
    
    specify "rank should be numerical" do
      lambda {
        t = create_rank(:rank => 'test')
        t.errors.on(:rank).should.not.be.nil
      }.should.not.change(Rank, :count)
    end

    specify "rank should be positive" do
      lambda {
        t = create_rank(:rank => 1)
        t.errors.on(:rank).should.be.nil
        t = create_rank(:rank => -1)
        t.errors.on(:rank).should.not.be.nil
      }.should.not.change(Rank, :count)
    end  
    
    specify "rank should be <= 4" do
      lambda {
        t = create_rank(:rank => 5)
        t.errors.on(:rank).should.not.be.nil
        t = create_rank(:rank => 4)
        t.errors.on(:rank).should.be.nil
      }.should.not.change(Rank, :count)
    end  
    
    specify "should require rank_type" do
      lambda {
        t = create_rank(:rank_type => nil)
        t.errors.on(:rank_type).should.not.be.nil
      }.should.not.change(Rank, :count)
   end
     
    def create_rank(options = {})
      Rank.create({ :rank => 1, :rank_type_id => 1, :project_id => 1 }.merge(options))  
    end                                                          
  end
end
