require File.dirname(__FILE__) + '/../test_helper'

context "Milestones" do
  fixtures :milestone_statuses, :projects, :milestones, :tasks

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :project_id => projects( :project_one ).id,
      :name => "valid milestone title",
      :milestone_status_id => milestone_statuses( :proposed ).id,
      :target_date => "2007-08-01",
      :description => "test valid milestone description"
    }.merge( overrides )
    Milestone.new( opts )
    # :id is a protected attribute.  Must set after creating instance
  end

  specify "new clean instance should validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( )
    instance.should.validate
    instance.save.should.equal( true )
    Milestone.count.should.equal( old_instance_count + 1 )
  end

  specify "each fixture instance should be valid" do
    Milestone.find( milestones( :one ).id ).should.validate
    Milestone.find( milestones( :two ).id ).should.validate
  end

  specify "create with nil project (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with zero project (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => 0 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with -1 project (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => -1 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with 98987 project (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => 98987 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with existing project (id) should validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => projects( :project_two ).id )
    instance.should.validate
    instance.save.should.equal( true )
    Milestone.count.should.equal( old_instance_count + 1 )
  end

  specify "create with nil name should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :name => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with empty name should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :name => "" )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with blank name should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :name => " " )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with duplicate name (same project) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => projects( :project_one ).id, :name => milestones( :one ).name )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with duplicate name (other project) should validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :project_id => projects( :project_two ).id, :name => milestones( :one ).name )
    instance.should.validate
    instance.save.should.equal( true )
    Milestone.count.should.equal( old_instance_count + 1 )
  end

  specify "create with nil description should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :description => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with empty description should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :description => "" )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with blank description should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :description => " " )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with valid description should validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :description => "this should be a valid description" )
    instance.should.validate
    instance.save.should.equal( true )
    Milestone.count.should.equal( old_instance_count + 1 )
  end

  specify "create with nil status (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :milestone_status_id => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with zero status (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :milestone_status_id => 0 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with -1 status (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :milestone_status_id => -1 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with 98987 status (id) should not validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :milestone_status_id => 98987 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Milestone.count.should.equal( old_instance_count )
  end

  specify "create with existing status (id) should validate" do
    old_instance_count = Milestone.count
    instance = clean_new_instance( :milestone_status_id => milestone_statuses( :canceled ).id )
    instance.should.validate
    instance.save.should.equal( true )
    Milestone.count.should.equal( old_instance_count + 1 )
  end

#  def test_edit_to_empty_description
#    # Should not be valid to modify an existing instance to have an empty or blank status
#    assert_invalid( Milestone.find( milestones( :one ).id ), :description, nil, "" )
#  end

  specify "destroy with child tasks should validate" do
    old_instance_count = Milestone.count
    instance = milestones( :one )
    instance_id = instance.id
    old_child_count = instance.tasks.count
    old_child_count.should.equal( 2 )
    old_child_count.should.be > 0
    old_child_count2 = Task.count
    instance.destroy#.should.equal( true )
    Milestone.count.should.equal( old_instance_count - 1 )
    Task.count.should.equal( old_child_count2 - 2 )
    Task.count.should.equal( old_child_count2 - old_child_count )
  end

  #destroy should fail if any history for Milestone (or delete the history too)
  #destroy should fail if any Task (or task history) using Milestone
end