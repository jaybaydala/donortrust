require File.dirname(__FILE__) + '/../../test_helper'

context "Groups" do
  fixtures :users, :groups, :memberships, :group_types

  def setup
  end

  specify "should not validate with nil name" do
    @group = test_group({ :name => nil })
    @group.should.not.validate
    @group.name = 'Test'
    @group.should.validate
  end

  specify "should validate with nil group_type_id" do
    @group = test_group({ :group_type_id => nil })
    @group.should.not.validate
    @group.group_type_id = 1
    @group.should.validate
  end

  specify "Group.name does not need to be unique" do
    @group = test_group()
    @group.save
    @group = test_group()
    @group.should.validate
  end
  
  specify "founder should return a User" do
    @group = Group.find(1)
    pp @group.user.class
  end
  
  protected
  def test_group(options={})
    Group.new({ :name => 'Test', :group_type_id => 1, :private => 0 }.merge(options))
  end
end
