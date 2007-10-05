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

  specify "should map { :controller => 'dt/projects', :action => 'specs', :id => 1} to /dt/projects/1;specs" do
    route_for(:controller => "dt/projects", :action => "specs", :id => 1).should == "/dt/projects/1;specs"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'village', :id => 1} to /dt/projects/1;village" do
    route_for(:controller => "dt/projects", :action => "village", :id => 1).should == "/dt/projects/1;village"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'nation', :id => 1} to /dt/projects/1;nation" do
    route_for(:controller => "dt/projects", :action => "nation", :id => 1).should == "/dt/projects/1;nation"
  end
  
  specify "should map { :controller => 'dt/projects', :action => 'community', :id => 1} to /dt/projects/1;community" do
    route_for(:controller => "dt/projects", :action => "community", :id => 1).should == "/dt/projects/1;community"
  end
  
  private 
  def route_for(options)
    @rs.generate options
  end
end

context "Dt::Projects index, show, specs, village, nation and community should exist" do
  use_controller Dt::ProjectsController
  specify "method should not exist" do
    %w( index show specs village nation community ).each do |m|
      @controller.methods.should.include m
    end
  end
end


context "Dt::Projects index behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses
  
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
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 1)
    get :show, :id => id
  end
  specify "The project overview should show the project name & description" do
    @project = Project.find(1)
    do_get(@project.id)
    status.should.be :success
    # use assert_select since the block type of `page.select "selector" do |foo|` seems to be borked
    assert_select "h1", :text => /#{@project.name}/
    assert_select "div#projectInfo" do
      assert_select "#projectDesc"
    end 
  end
  
  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav"
  end

  specify "should contain quick facts (#factList)" do
    do_get
    page.should.select "div#factList ul"
  end
  
  specify "should contain #relatedProjects" do
    do_get
    assert_select "div#relatedProjects"
  end

  specify "should contain \"Gift It\" link which goes to dt/gifts/new?project_id=x" do
    project_id = 1
    do_get(project_id)
    assert_select "div#buttonGiftProject" do
      assert_select "a[href=/dt/gifts/new?project_id=#{project_id}]"
    end
  end

  specify "should contain \"Donate\" link which goes to dt/investments/new" do
    project_id = 1
    do_get(project_id)
    assert_select "div#buttonDonate" do
      assert_select "a[href=/dt/investments/new?project_id=#{project_id}]"
    end
  end

  specify "should contain \"Tell a Friend\" link which goes to dt/shares/new" do
    project_id = 1
    do_get(project_id)
    assert_select "div#buttonTellFriend" do
      assert_select "a[href=/dt/shares/new?project_id=#{project_id}]"
    end
  end
end

context "Dt::Projects village behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 1)
    get :village, :id => id
  end
  
  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav"
  end
  
  specify "should assign projects and village" do
    do_get 
    assigns(:project).should.not.be.nil
    assigns(:village).should.not.be.nil
  end
end

context "Dt::Projects nation behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 1)
    get :nation, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav"
  end

  specify "should assign projects and village" do
    do_get 
    assigns(:project).should.not.be.nil
    assigns(:nation).should.not.be.nil
  end
end

context "Dt::Projects community behaviour" do
  use_controller Dt::ProjectsController
  fixtures :projects, :places, :programs, :partners, :project_statuses

  def do_get(id = 1)
    get :community, :id => id
  end

  specify "should contain the project_nav (#subNav)" do
    do_get
    assert_select "div#subNav"
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
