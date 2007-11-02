require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/group_projects_controller'

# Re-raise errors caught by the controller.
class Dt::GroupProjectsController; def rescue_action(e) raise e end; end

context "Dt::GroupProjects inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::GroupProjectsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::GroupProjects #route_for" do
  use_controller Dt::GroupProjectsController
  setup do
    @rs = ActionController::Routing::Routes
  end
  
  specify "should map { :controller => 'dt/group_projects', :action => 'index', :group_id => 1 } to /dt/groups/1/group_projects" do
    route_for(:controller => "dt/group_projects", :action => "index", :group_id => 1).should == "/dt/groups/1/group_projects"
  end

  specify "should map { :controller => 'dt/group_projects', :action => 'new', :group_id => 1 } to /dt/groups/1/group_projects/new" do
    route_for(:controller => "dt/group_projects", :action => "new", :group_id => 1).should == "/dt/groups/1/group_projects/new"
  end

  specify "should map { :controller => 'dt/group_projects', :action => 'create', :group_id => 1 } to /dt/groups/1/group_projects" do
    route_for(:controller => "dt/group_projects", :action => "create", :group_id => 1).should == "/dt/groups/1/group_projects"
  end

  specify "should map { :controller => 'dt/group_projects', :action => 'destroy', :id => 1, :group_id => 1 } to /dt/groups/1/group_projects/1" do
    route_for(:controller => "dt/group_projects", :action => "destroy", :id => 1, :group_id => 1).should == "/dt/groups/1/group_projects/1"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::GroupProjects %w(index destroy) should exist "do
  use_controller Dt::GroupProjectsController
  specify "methods should exist" do
    %w( index destroy ).each do |m|
      @controller.methods.should.include m
    end
  end
end
context "Dt::GroupProjects %w(show new create edit update) should not exist "do
  use_controller Dt::GroupProjectsController
  specify "methods should not exist" do
    %w( show new create edit update ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end

context "Dt::GroupProjects index handling" do
  use_controller Dt::GroupProjectsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types, :investments, :partners

  specify "should not redirect if not logged_in" do
    get :index, :group_id => 1
    should.not.redirect
  end

  specify "should assign @group" do
    get :index, :group_id => 1
    assigns(:group).should.not.be nil
  end

  specify "should assign @projects_invested && @projects_watched" do
    get :index, :group_id => 1
    assigns(:projects_invested).should.not.be nil
    assigns(:projects_watched).should.not.be nil
  end

  specify "should show subnav" do
    get :index, :group_id => 1
    page.should.select "#subNavWide"
  end

  specify "should show subSubNav" do
    get :index, :group_id => 1
    page.should.select "#subSubNav_2col"
  end

  specify "should assign projects_invested and projects_watched" do
    login_as :quentin
    get :index, :group_id => 1
    assigns(:projects_invested).should.not.be.nil
    assigns(:projects_watched).should.not.be.nil
    #page.should.select 
  end
end

context "Dt::GroupProject delete handling" do
  use_controller Dt::GroupProjectsController
  include DtAuthenticatedTestHelper
  fixtures :users, :groups, :memberships, :group_types, :investments, :partners, :projects
  
  specify "should redirect if not logged_in" do
    delete :destroy, :group_id => 1, :id => 1
    should.redirect
    flash[:notice].should.be.nil
  end

  specify "should redirect if not a member" do
    login_as(:aaron)
    delete :destroy, :group_id => 1, :id => 1
    should.redirect :controller => 'dt/group_projects', :group_id => 1
    flash[:notice].should.be.nil
  end

  specify "should redirect if not admin?" do
    login_as(:aaron)
    delete :destroy, :group_id => 1, :id => 1
    should.redirect :controller => 'dt/group_projects', :group_id => 1
    flash[:notice].should.be.nil
  end
  
  specify "should delete if admin?" do
    login_as(:aaron)
    @group = Group.find(2)
    @group.projects << Project.find(3)
    old_count = @group.projects.size
    delete :destroy, :group_id => @group.id, :id => 3
    @group.projects(true).size.should.equal old_count-1
    should.redirect :controller => 'dt/group_projects', :group_id => 2
    flash[:notice].should =~ %r(^You have removed the)
  end

  specify "should delete if founder?" do
    login_as(:tim)
    @group = Group.find(2)
    @group.projects << Project.find(3)
    old_count = @group.projects.size
    delete :destroy, :group_id => @group.id, :id => 3
    @group.projects(true).size.should.equal old_count-1
    should.redirect :controller => 'dt/group_projects', :group_id => 2
    flash[:notice].should =~ %r(^You have removed the)
  end
end
