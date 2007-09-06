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

context "As a donor I want to view project-specific content so I can give to the project knowing what it's about" do
  fixtures :continents, :countries, :regions, :urban_centres, :projects
  
  setup do
    @controller = Dt::ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  specify "Project index is available" do
    @project = Project.find(1)
    get :index
    status.should.be :success
  end

  specify "The project overview should show the project name & description" do
    @project = Project.find(1)
    get :show, :id => @project.id
    status.should.be :success
    # use assert_select since the block type of `page.select "selector" do |foo|` seems to be borked
    assert_select "div#project-#{@project.id}" do
      assert_select "#project-name", :text => /#{@project.name}/
      assert_select "#project-description"
    end 
  end

  specify "See the project's categories" do
  end

  specify "Project village page should show village information" do
  end

  specify "Project nation page should show nation information" do
  end

  specify "Project community page should show village information" do
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
