require File.dirname(__FILE__) + '/../test_helper'

context "Rank Type Tests " do
  fixtures :rank_types
 
  specify "should create a rank type" do
    RankType.should.differ(:count).by(1) { create_rank_type } 
  end
   
  specify "should require name" do
    lambda {
      t = create_rank_type(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(RankType, :count)
  end
  
  def create_rank_type(options = {})
    RankType.create({ :name => 'Test Name', :description => 'My Description' }.merge(options))  
  end
end
