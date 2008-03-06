module GroupPermissionsTestHelper
  def setup_group_permissions
    @member = stub_everything("member", :id => 1, :to_param => "1", :member? => true, :admin? => false, :founder? => false)
    @admin = stub_everything("admin", :id => 2, :to_param => "2", :member? => true, :admin? => true, :founder? => false)
    @founder = stub_everything("founder", :id => 3, :to_param => "3", :member? => true, :admin? => true, :founder? => true)

    @memberships = stub_everything("memberships")
    
    @group = stub_everything("Group", :id => 1, :to_param => "1", :private? => false, :memberships => @memberships, :name => "Sample Group")
    Group.stubs(:find).returns(@group)
  end
end