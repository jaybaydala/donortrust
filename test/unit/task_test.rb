require File.dirname(__FILE__) + '/../test_helper'

context "Tasks" do
  fixtures :milestones, :tasks

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :milestone_id => milestones( :one ).id,
      :name => "clean task instance name",
      :description => "clean task instant description"
    }.merge( overrides )
    instance = Task.new( opts )
    # :milestone_id is a protected attribute.  Must set [separately] after creating instance
    instance.milestone_id = opts[ :milestone_id ]
    instance
  end

  specify "new clean instance should validate" do
    old_instance_count = Task.count
    #must use .find_with_deleted instead of just .find with :from, because acts_as_paranoid
    #inserts tasks.deleted_at references in the SQL select statement, even though (here) the
    #select is referencing the task_versions table instead of tasks.
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( )
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count + 1 )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "each fixture instance should be valid" do
    Task.find( tasks( :taskone ).id ).should.validate
    Task.find( tasks( :tasktwo ).id ).should.validate
  end

  specify "create with nil milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :milestone_id => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with zero milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :milestone_id => 0 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with -1 milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :milestone_id => -1 )
    instance.should.not.validate
    instance.save
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with 98987 milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :milestone_id => 98987 )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with existing milestone (id) should validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :milestone_id => milestones( :two ).id )
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count + 1 )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with nil name should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :name => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with empty name should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :name => "" )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with blank name should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :name => " " )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with duplicate name (same milestone) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :name => tasks( :taskone ).name )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with duplicate name for other milestone id should validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :milestone_id => milestones( :two ).id, :name => tasks( :taskone ).name )
    instance.should.validate
    instance.save
    Task.count.should.equal( old_instance_count + 1 )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with nil description should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :description => nil )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with empty description should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :description => "" )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "create with blank description should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :description => " " )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to nil milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.milestone_id = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to 0 milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.milestone_id = 0
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to -1 milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.milestone_id = -1
    instance.should.not.validate
    instance.save
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to 98989 milestone (id) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.milestone_id = 98989
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  # probably should not be valid to change the milestone (id) associated with a task
  # IE moving the existing task to a different milestone
  specify "edit to other milestone id should validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.milestone_id = milestones( :two ).id
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to nil name should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.name = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to empty name should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.name = ""
    instance.should.not.validate
    instance.save
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to blank name should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.name = " "
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to duplicate name (same milestone) should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.name = tasks( :tasktwo ).name
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to name used in other milestone task should validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.name = tasks( :taskthree ).name
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to nil description should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.description = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to empty description should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.description = ""
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit to blank description should not validate" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.description = " "
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit description should create new version record" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.description = "new test description"
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit start date should create new version record" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.start_date = '2008-02-10'
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit end date should create new version record" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.end_date = '2008-02-10'
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "edit etc date should create new version record" do
    old_instance_count = Task.count
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.etc_date = '2008-02-10'
    instance.should.validate
    instance.save.should.equal( true )
    Task.count.should.equal( old_instance_count )
    ( old_version_count + 1 ).should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "destroy existing instance should validate (but not actually delete)" do
    old_instance_count = Task.count
    old_instance_count_all = Task.find_with_deleted( :all ).size
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :taskone ).id )
    instance.deleted_at.should.equal( nil )
    existing_id = instance.id
    existing_name = instance.name
    instance.destroy
    Task.count.should.equal( old_instance_count - 1 )
    old_instance_count_all.should.equal( Task.find_with_deleted( :all ).size )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
    still_here = Task.find_with_deleted( existing_id )
    still_here.name.should.equal existing_name
    still_here.deleted_at.should.not.equal( nil )
  end

  specify "create with name matching destroyed record should not validate" do
    instance = Task.find( tasks( :taskone ).id )
    existing_name = instance.name
    instance.destroy
    old_instance_count = Task.count
    old_instance_count_all = Task.find_with_deleted( :all ).size
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = clean_new_instance( :name => existing_name )
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_instance_count_all.should.equal( Task.find_with_deleted( :all ).size )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end

  specify "update name to match destroyed record should not validate" do
    instance = Task.find( tasks( :taskone ).id )
    existing_name = instance.name
    instance.destroy
    old_instance_count = Task.count
    old_instance_count_all = Task.find_with_deleted( :all ).size
    old_version_count = Task.find_with_deleted( :all, :from => "task_versions" ).size
    instance = Task.find( tasks( :tasktwo ).id )
    instance.name = existing_name
    instance.should.not.validate
    instance.save.should.equal( false )
    Task.count.should.equal( old_instance_count )
    old_instance_count_all.should.equal( Task.find_with_deleted( :all ).size )
    old_version_count.should.equal( Task.find_with_deleted( :all, :from => "task_versions" ).size )
  end
end