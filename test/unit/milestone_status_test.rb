require File.dirname(__FILE__) + '/../test_helper'

context "MilestoneStatuses" do
  fixtures :milestone_statuses, :milestones

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :name => "xyzstatusxyz",
      :description => "Valid description for status"
    }.merge( overrides )
    MilestoneStatus.new( opts )
  end

  specify "new clean instance should validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance()
    instance.should.validate
    instance.save.should.equal( true )
    MilestoneStatus.count.should.equal( old_instance_count + 1 )
  end

  specify "create with nil name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :name => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with empty name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :name => "" )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with blank name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :name => " " )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with nil description should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :description => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with empty description should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :description => "" )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with blank description should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :description => " " )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with duplicate name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :name => milestone_statuses( :proposed ).name )
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "create with new name should validate" do
    old_instance_count = MilestoneStatus.count
    instance = clean_new_instance( :name => "new name" )
    instance.should.validate
    instance.save.should.equal( true )
    MilestoneStatus.count.should.equal( old_instance_count + 1 )
  end

  specify "modify existing record to nil name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.name = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to empty name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.name = ""
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to blank name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.name = " "
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to nil description should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.description = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to empty description should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.description = ""
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to blank description should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.description = " "
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to (other) existing name should not validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.name = milestone_statuses( :complete ).name
    instance.should.not.validate
    instance.save.should.equal( false )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to new unigue name should validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.name = "new one"
    instance.should.validate
    instance.save.should.equal( true )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify description of existing record should validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.description = "some new description"
    instance.should.validate
    instance.save.should.equal( true )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "modify description of existing record to duplicate of other should validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    instance.description = milestone_statuses( :complete ).description
    instance.should.validate
    instance.save.should.equal( true )
    MilestoneStatus.count.should.equal( old_instance_count )
  end

  specify "destroy existing (unused) record should validate" do
    old_instance_count = MilestoneStatus.count
    instance = MilestoneStatus.find( milestone_statuses( :canceled ).id )
    instance.destroy
    MilestoneStatus.count.should.equal( old_instance_count - 1 )
  end

## hpd how to verify that destroy fails.  As is this gets an exception instead of catching
## and displaying the failure.
#  specify "destroy record used by Milestone should not validate" do
#    old_instance_count = MilestoneStatus.count
#    instance = MilestoneStatus.find( milestone_statuses( :proposed ).id )
#    instance.destroy.should.raise "Can not destroy a MilestoneStatus that has Milestones"
#  end

end
