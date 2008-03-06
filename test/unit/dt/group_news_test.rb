require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "GroupNews" do
  include DtAuthenticatedTestHelper
  setup do
  end
  
  def create_group_news(options = {})
    GroupNews.create({:user_id => 1, :group_id => 1, :message => 'foo'}.merge(options))
  end
  
  specify "GroupNews table should be 'group_news'" do
    GroupNews.table_name.should.equal 'group_news'
  end

  specify "should create a wall post" do
    GroupNews.should.differ(:count).by(1) { create_group_news }
  end
  
  specify "should require user_id" do
    lambda {
      t = create_group_news(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(GroupNews, :count)
  end
  
  specify "should require a group_id" do
    lambda {
      t = create_group_news(:group_id => nil)
      t.errors.on(:group_id).should.not.be.nil
    }.should.not.change(GroupNews, :count)
  end
  
  specify "should require a message" do
    lambda {
      t = create_group_news(:message => nil)
      t.errors.on(:message).should.not.be.nil
    }.should.not.change(GroupNews, :count)
  end
end