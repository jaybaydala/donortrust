require File.dirname(__FILE__) + '/../test_helper'

context "GroupTypes" do
  fixtures :group_types

  def setup
    @test_instance = GroupType.find(1)
  end

  specify "should not validate with nil name" do
    @test_instance.should.validate
    @test_instance.name = nil
    @test_instance.should.not.validate
  end
end
