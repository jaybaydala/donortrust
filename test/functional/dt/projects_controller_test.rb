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

context "Dt::Projects index behaviour" do
  use_controller Dt::ProjectsController
  fixtures :continents, :countries, :regions, :urban_centres, :projects
  
  specify "Project index is available" do
    @project = Project.find(1)
    get :index
    status.should.be :success
  end

  xspecify "need to add project list/search specs" do
  end
end

context "Dt::Projects show behaviour" do
  use_controller Dt::ProjectsController
  fixtures :continents, :countries, :regions, :urban_centres, :projects

  def do_get(id)
    get :show, :id => id
  end
  specify "The project overview should show the project name & description" do
    @project = Project.find(1)
    do_get(@project.id)
    status.should.be :success
    # use assert_select since the block type of `page.select "selector" do |foo|` seems to be borked
    assert_select "div#project-#{@project.id}" do
      assert_select "#project-name", :text => /#{@project.name}/
      assert_select "#project-description"
    end 
  end
  
  specify "should contain the project_nav (#subNav)" do
    
  end

  specify "should contain quick facts" do
  end
  
  specify "should contain #relatedProjects" do
    assert_select "div#relatedProjects"
  end

  specify "should contain \"Gift It\" link which goes to dt/gifts/new" do
  end

  specify "should contain \"Donate\" link which goes to dt/investments/new" do
  end

  specify "should contain \"Tell a Friend\" link which goes to dt/share/new" do
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

#context "As a donor I want to view nation-level content so I can see the project in context of the nation" do
#  fixtures :projects
#  
#  setup do
#    @controller = Dt::ProjectsController.new
#    @request    = ActionController::TestRequest.new
#    @response   = ActionController::TestResponse.new
#  end
#
#  xspecify "Show nation name & description" do
#  end
#
#  xspecify "Link to nation 'Further Reading' - model should have a link and a link description" do
#  end
#end
#
#context "As a donor I want to view village-level content so I can see the project in context of the village" do
#  fixtures :projects
#  
#  setup do
#    @controller = Dt::ProjectsController.new
#    @request    = ActionController::TestRequest.new
#    @response   = ActionController::TestResponse.new
#  end
#
#  xspecify "Show village name & description" do
#  end
#
#  xspecify "Show village goals/plan" do
#  end
#end
