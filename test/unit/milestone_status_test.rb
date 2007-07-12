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

  setup do
#    @status = MilestoneStatus.find(1)
#    @status = milestone_statuses( :proposed )
  end

  specify "new clean instance should validate" do
    clean_new_instance( ).should.validate
  end

  specify "nil name should not validate" do
    clean_new_instance( :name => nil ).should.not.validate
  end

  specify "empty name should not validate" do
    clean_new_instance( :name => "" ).should.not.validate
  end

  specify "blank name should not validate" do
    clean_new_instance( :name => " " ).should.not.validate
  end

  specify "nil description should not validate" do
    MilestoneStatus.new( :description => nil ).should.not.validate
  end

  specify "empty description should not validate" do
    MilestoneStatus.new( :description => "" ).should.not.validate
  end

  specify "blank description should not validate" do
    MilestoneStatus.new( :description => " " ).should.not.validate
  end

  specify "new duplicate name should not validate" do
    clean_new_instance( :name => milestone_statuses( :proposed ).name ).should.not.validate
  end

  specify "new original name should validate" do
    clean_new_instance( :name => "new name" ).should.validate
  end

  specify "modify existing record to nil name should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.name = nil
    @sts.should.not.validate
  end

  specify "modify existing record to empty name should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.name = ""
    @sts.should.not.validate
  end

  specify "modify existing record to blank name should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.name = " "
    @sts.should.not.validate
  end

  specify "modify existing record to nil description should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.description = nil
    @sts.should.not.validate
  end

  specify "modify existing record to empty description should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.description = ""
    @sts.should.not.validate
  end

  specify "modify existing record to blank description should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.description = " "
    @sts.should.not.validate
  end

  specify "modify existing record to (other) existing name should not validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.name = milestone_statuses( :complete ).name
    @sts.should.not.validate
  end

  specify "modify existing record to new unigue name should validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.name = "new one"
    @sts.should.validate
  end

  specify "modify description of existing record should validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.description = "some new description"
    @sts.should.validate
  end

  specify "modify description of existing record to duplicate of other should validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
    @sts.description = milestone_statuses( :complete ).description
    @sts.should.validate
  end

  specify "destroy existing (unused) record should validate" do
    @sts = MilestoneStatus.find( milestone_statuses( :canceled ).id )
    @sts.destroy.should.validate
  end

## hpd how to verify that destroy fails.  As is this gets an exception instead of catching
#  specify "destroy record used by Milestone should not validate" do
#    @sts = MilestoneStatus.find( milestone_statuses( :proposed ).id )
#    @sts.destroy.should.raise "Can not destroy a MilestoneStatus that has Milestones"
#  end

end
