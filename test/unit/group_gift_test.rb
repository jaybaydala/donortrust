require File.dirname(__FILE__) + '/../test_helper'

context "Group Gift Tests " do
  fixtures :group_gifts
  
  specify "should create a group gift" do
    GroupGift.should.differ(:count).by(1) {create_group_gift} 
  end   
 
 def create_group_gift(options = {})
  GroupGift.create({ :first_name => 'Test', :last_name => 'last', :email => 'test@test.ca' }.merge(options))  
 end    
end
