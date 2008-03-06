require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "GroupWallMessage" do
  include DtAuthenticatedTestHelper
  setup do
  end
  
  def create_group_wall(options = {})
    GroupWallMessage.create({:user_id => 1, :group_id => 1, :message => 'foo'}.merge(options))
  end
  
  specify "GroupWallMessage table should be 'group_wall_messages'" do
    GroupWallMessage.table_name.should.equal 'group_wall_messages'
  end

  specify "should create a wall post" do
    GroupWallMessage.should.differ(:count).by(1) { create_group_wall }
  end
  
  specify "should require user_id" do
    lambda {
      t = create_group_wall(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(GroupWallMessage, :count)
  end
  
  specify "should require a group_id" do
    lambda {
      t = create_group_wall(:group_id => nil)
      t.errors.on(:group_id).should.not.be.nil
    }.should.not.change(GroupWallMessage, :count)
  end
  
  specify "should require a message" do
    lambda {
      t = create_group_wall(:message => nil)
      t.errors.on(:message).should.not.be.nil
    }.should.not.change(GroupWallMessage, :count)
  end
end