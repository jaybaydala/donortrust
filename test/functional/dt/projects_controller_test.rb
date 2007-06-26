require File.dirname(__FILE__) + '/../../test_helper'
require 'dt/projects_controller'
require 'pp'

# Re-raise errors caught by the controller.
class DT::ProjectsController; def rescue_action(e) raise e end; end

context "As a donor I want to view project-specific content so I can give to the project knowing what it's about" do
  fixtures :projects
  
  setup do
    @controller = Dt::ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  specify "The project overview should show the project name & description" do
    @project = Project.find(1)
    get :show, :id => @project.id
    status.should.be :success
    page.should.select "div#project-#{@project.id}" do |div|
      div.should.select "div[class=project-name]"
      #, :text => /#{@project.name}/
      #project.should.select "#project-description", :text => /#{@project.description}/
    end
  end

  xspecify "See the project's categories" do
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
