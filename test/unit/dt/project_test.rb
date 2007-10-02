require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'

context "As a donor I want to view project-specific content so I can give to the project knowing what it's about" do
  fixtures :projects, :places
  
  setup do
  end

  specify "The project should have a project name & description" do
    @project = Project.find(1)
    @project.name.should.not.be.nil
    @project.description.should.not.be.nil
  end

  specify "A project's village should be available through @project.village, etc." do
    @project = Project.find(1)
    @project.village_id
    @project.village_id?.should.be true
    @project.village.should.not.be.nil
  end

  specify "A project's nation should be available through @project.nation, etc." do
    @project = Project.find(1)
    @project.nation_id.should == 2 #uganda
    @project.nation_id?.should.be true
    @project.nation.should.not.be.nil
  end

  specify "should return village_projects_count as an int" do
    @project = Project.find(1)
    @project.village_project_count.should >= 0
  end
  
  specify "should return total_cost, dollars_spent, dollars_raised and current_need" do
    @project = Project.find(1)
    @project.total_cost.should.be > 0
    @project.dollars_spent.should.be >= 0
    @project.dollars_raised.should.be >= 0
    @project.current_need.should.equal @project.total_cost - @project.dollars_raised
  end
  
end
