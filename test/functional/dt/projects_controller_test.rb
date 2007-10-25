require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/projects_controller'

# Re-raise errors caught by the controller.
class Dt::ProjectsController; def rescue_action(e) raise e end; end

context "Dt::Projects inheritance" do
  specify "should inherit from DtApplicationController" do
    @controller = Dt::ProjectsController.new
    @controller.kind_of?(DtApplicationController).should == true
  end
end

context "Dt::Projects #route_for" do
  use_controller Dt::ProjectsController
  setup do
    @rs = ActionController::Routing::Routes
  end
    
  specify "should map { :controller => 'dt/projects', :action => 'index' } to /dt/projects" do
    route_for(:controller => "dt/projects", :action => "index").should == "/dt/projects"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'show', :id => 1 } to /dt/projects/1" do
    route_for(:controller => "dt/projects", :action => "show", :id => 1).should == "/dt/projects/1"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'new' } to /dt/projects/new" do
    route_for(:controller => "dt/projects", :action => "new").should == "/dt/projects/new"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'create' } to /dt/projects/new" do
    route_for(:controller => "dt/projects", :action => "new").should == "/dt/projects/new"
  end
    
  specify "should map { :controller => 'dt/projects', :action => 'edit', :id => 1 } to /dt/projects/1;edit" do
    route_for(:controller => "dt/projects", :action => "edit", :id => 1).should == "/dt/projects/1;edit"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'update', :id => 1} to /dt/projects/1" do
    route_for(:controller => "dt/projects", :action => "update", :id => 1).should == "/dt/projects/1"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'destroy', :id => 1} to /dt/projects/1" do
    route_for(:controller => "dt/projects", :action => "destroy", :id => 1).should == "/dt/projects/1"
  end

  specify "should map { :controller => 'dt/projects', :action => 'details', :id => 1} to /dt/projects/1;details" do
    route_for(:controller => "dt/projects", :action => "details", :id => 1).should == "/dt/projects/1;details"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'community', :id => 1} to /dt/projects/1;community" do
    route_for(:controller => "dt/projects", :action => "community", :id => 1).should == "/dt/projects/1;community"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'nation', :id => 1} to /dt/projects/1;nation" do
    route_for(:controller => "dt/projects", :action => "nation", :id => 1).should == "/dt/projects/1;nation"
  end

  specify "should map { :controller => 'dt/projects', :action => 'organization', :id => 1} to /dt/projects/1;organization" do
    route_for(:controller => "dt/projects", :action => "organization", :id => 1).should == "/dt/projects/1;organization"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'connect', :id => 1} to /dt/projects/1;connect" do
    route_for(:controller => "dt/projects", :action => "connect", :id => 1).should == "/dt/projects/1;connect"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Projects index, show, details, community, nation and connect   should exist" do
  use_controller Dt::ProjectsController
  specify "method should not exist" do
    %w( index show details community nation organization connect ).each do |m|
      @controller.methods.should.include m
    end
  end
end


context "Dt::Projects index behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses, :users, :groups, :memberships
  include DtAuthenticatedTestHelper
  
  specify "Project index is available" do
    @project = Project.find(1)
    get :index
    status.should.be :success
  end

  specify "should show a list of featured projects" do
    get :index
    page.should.select "#featuredProjectList"
  end

  specify "should have @projects assigned" do
    get :index
    assigns(:projects).should.not.be.nil
  end
end

context "Dt::Projects show behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses, :users, :groups, :memberships
  include DtAuthenticatedTestHelper

  def do_get(id = 2)
    get :show, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav" do
      assert_select "ul.subNav"
    end
  end

  specify "should use show template" do
    do_get
    template.should.be 'dt/projects/show'
  end
  
  specify "should not show a project that is not public" do
    project = Project.find_public(:first)
    project.project_status_id = 1
    project.save
    do_get
    status.should.be 404
  end

  specify "The project overview should show the project name & description" do
    @project = Project.find(2)
    do_get(@project.id)
    status.should.be :success
    # use assert_select since the block type of `page.select "selector" do |foo|` seems to be borked
    assert_select "h1", :text => /#{@project.name}/
    assert_select "div#leftColW" do
      assert_select "div.projectRank" do
        assert_select "ul.specList"
      end
      assert_select "div.projectDescription"
    end 
    assert_select "div#rightColN" do
      assert_select "div#relatedProjects"
      assert_select "div#factList"
    end
  end
  
  specify "should contain quick facts (#factList)" do
    do_get
    page.should.select "div#factList ul"
  end

  specify "if logged_in, should show a Add to My Wishlist link in div#factList" do
    login_as(:quentin)
    project_id = 2
    do_get project_id
    page.should.select "div#factList ul li[class=blueblock] a[href=#{dt_new_my_wishlist_path(:account_id => users(:quentin), :project_id => project_id)}]"
  end

  specify "if logged_in and group_admin?, should show a Add to Group Wishlist link in div#factList" do
    login_as(:quentin)
    project_id = 2
    do_get project_id
    page.should.select "div#factList ul li[class=blueblock] a[href=#{dt_new_wishlist_path(:project_id => project_id)}]"
  end

  specify "if logged_in and group_admin? is false, should not show a Add to Group Wishlist link in div#factList" do
    login_as(:quentin)
    users(:quentin).memberships.each do |m|
      m.membership_type = Membership.member
      m.save
    end
    users(:quentin).group_admin?.should.be false
    project_id = 2
    do_get project_id
    page.should.not.select "div#factList ul li[class=blueblock] a[href=#{dt_new_wishlist_path(:project_id => project_id)}]"
  end
  
  specify "should contain #relatedProjects" do
    do_get
    assert_select "div#relatedProjects"
  end

  specify "should contain \"Gift It\" link which goes to dt/gifts/new?project_id=x" do
    project_id = 2
    do_get(project_id)
    assert_select "div#buttonGiftProject" do
      assert_select "a[href=/dt/gifts/new?project_id=#{project_id}]"
    end
  end

  specify "should contain \"Donate\" link which goes to dt/investments/new" do
    project_id = 2
    do_get(project_id)
    assert_select "div#buttonDonate" do
      assert_select "a[href=/dt/investments/new?project_id=#{project_id}]"
    end
  end

  specify "should contain \"Tell a Friend\" link which goes to dt/tell_friends/new" do
    project_id = 2
    do_get(project_id)
    assert_select "div#buttonTellFriend" do
      assert_select "a[href=/dt/tell_friends/new?project_id=#{project_id}]"
    end
  end
end

context "Dt::Projects details behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 2)
    get :details, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav" do
      assert_select "ul.subNav"
    end
  end

  specify "should use details template" do
    do_get
    template.should.be 'dt/projects/details'
  end

  specify "should not show a project that is not public" do
    project = Project.find_public(:first)
    project.project_status_id = 1
    project.save
    do_get
    status.should.be 404
  end
end

context "Dt::Projects community behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 2)
    get :community, :id => id
  end
  
  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav" do
      assert_select "ul.subNav"
    end
  end
  
  specify "should use community template" do
    do_get
    template.should.be 'dt/projects/community'
  end

  specify "should assign projects and community" do
    do_get 
    assigns(:project).should.not.be.nil
    assigns(:community).should.not.be.nil
  end

  specify "should not show a project that is not public" do
    project = Project.find_public(:first)
    project.project_status_id = 1
    project.save
    do_get
    status.should.be 404
  end
end

context "Dt::Projects nation behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 2)
    get :nation, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav" do
      assert_select "ul.subNav"
    end
  end

  specify "should assign projects and community" do
    do_get 
    assigns(:project).should.not.be.nil
    assigns(:nation).should.not.be.nil
  end

  specify "should use nation template" do
    do_get
    template.should.be 'dt/projects/nation'
  end

  specify "should not show a project that is not public" do
    project = Project.find_public(:first)
    project.project_status_id = 1
    project.save
    do_get
    status.should.be 404
  end
end

context "Dt::Projects organization behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 2)
    get :organization, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav" do
      assert_select "ul.subNav"
    end
  end

  specify "should use organization template" do
    do_get
    template.should.be 'dt/projects/organization'
  end
  
  specify "should assign @project and @organization" do
    do_get
    assigns(:project).id.should.equal 2
    assigns(:organization).id.should.equal assigns(:project).partner_id
  end

  specify "should not show a project that is not public" do
    project = Project.find_public(:first)
    project.project_status_id = 1
    project.save
    do_get
    status.should.be 404
  end
end


context "Dt::Projects connect behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 2)
    get :connect, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav" do
      assert_select "ul.subNav"
    end
  end

  specify "should not show a project that is not public" do
    project = Project.find_public(:first)
    project.project_status_id = 1
    project.save
    do_get
    status.should.be 404
  end
end


context "Dt::Projects new, create, edit, update and destroy should not exist" do
  use_controller Dt::ProjectsController
  specify "method should not exist" do
    %w( new create edit update destroy ).each do |m|
      @controller.methods.should.not.include m
    end
  end
end
