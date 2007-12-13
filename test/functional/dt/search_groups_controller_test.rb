require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/search_groups_controller'

# Re-raise errors caught by the controller.
class Dt::SearchGroupsController; def rescue_action(e) raise e end; end

context "Dt::SearchGroupsController inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::SearchGroupsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::SearchGroupsController #route_for" do
  use_controller Dt::SearchGroupsController
  setup do
    @rs = ActionController::Routing::Routes
  end

  specify "should map { :controller => 'dt/projects', :action => 'show', :id => 1 } to /dt/projects/1" do
    route_for(:controller => "dt/projects", :action => "show", :id => 1).should == "/dt/projects/1"
  end

  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::SearchGroupsController show behaviour" do
  use_controller Dt::SearchGroupsController
  
  specify "should use show template" do
    get :show, :q => 'test'
    template.should.be 'dt/search_groups/show'
  end

  specify "should assign @groups" do
    get :show, :q => 'test'
    assigns(:groups).should.not.be.nil
  end

  specify "should paginate" do
    Group.stubs(:paginate).returns([Group.new, Group.new, Group.new])
    get :show, :q => 'test'
    assigns(:groups).should.not.be.nil
  end

  specify "should return 1 result" do
    GroupType.stubs(:find).returns(GroupType.new)
    Group.any_instance.stubs(:group_type).returns(GroupType.find(:first))
    Group.any_instance.stubs(:private).returns(false)
    
    i = 1
    Group.searchable_columns.each do |k|
      group = Group.new
      group.name = 'required'
      group[k]= 'test'
      group.private = false
      group.save!

      get :show, :q => 'test'
      assigns(:groups).size.should == i
      assigns(:groups)[i-1][k].should.equal 'test'
      i += 1
    end
  end
end
