require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'

context "As a donor I want to view project-specific content so I can give to the project knowing what it's about" do
  fixtures :continents
  fixtures :countries
  fixtures :regions
  fixtures :urban_centres
  fixtures :projects
  
  setup do
  end

  specify "The project should have a project name & description" do
    @project = Project.find(1)
    @project.name.should.not.be.nil
    @project.description.should.not.be.nil
  end

  specify "A project's village should be available through @project.urban_centre or @project.village" do
    @project = Project.find(1)
    @project.village.should.not.be.nil
    @project.urban_centre.should.equal @project.village
  end
end
