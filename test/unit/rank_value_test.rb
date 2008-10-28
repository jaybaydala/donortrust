require File.dirname(__FILE__) + '/../test_helper'

context "Quick Fact Sector Tests " do
  fixtures :rank_values
 
  specify "should create a rank value" do
    RankValue.should.differ(:count).by(1) {create_rank_value} 
  end
   
  specify "should require file" do
    lambda {
      t = create_rank_value(:file => nil)
      t.errors.on(:file).should.not.be.nil
    }.should.not.change(RankValue, :count)
  end
    
  def create_rank_value(options = {})
    RankValue.create({ :rank_value => 1, :file => uploaded_file(file_path("test.jpg"), "image/jpeg", "test") }.merge(options))
  end           
  
  def file_path(filename)
    File.expand_path("#{File.dirname(__FILE__)}/image/#{filename}")
  end
end
