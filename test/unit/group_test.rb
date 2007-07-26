require File.dirname(__FILE__) + '/../test_helper'

#class BusAdmin::GroupTest < Test::Unit::TestCase
context "Groups" do
  fixtures :groups

  def setup
    @group = Group.find(1)
  end

  specify "should not validate with nil name" do
    @group.should.validate
    @group.name = nil
    @group.should.not.validate
  end
  
end
