require File.dirname(__FILE__) + '/../../test_helper'

context "Group Types" do
  fixtures :groups, :group_types

  def setup
  end

  specify "should not validate with nil name" do
    @group = test_group_type({ :name => nil })
    @group.should.not.validate
    @group.name = 'Test'
    @group.should.validate
  end

  specify "GroupType.name should be unique" do
    @group = test_group_type()
    @group.save
    @group = test_group_type()
    @group.should.not.validate
  end
  
  protected
  def test_group_type(options={})
    GroupType.new({ :name => 'Test' }.merge(options))
  end
end
