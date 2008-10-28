require File.dirname(__FILE__) + '/../test_helper'

context "ProjectStatusTest handling GET " do
  fixtures :project_statuses
  
  specify "should create a project status" do
    ProjectStatus.should.differ(:count).by(1) {create_project_status} 
  end 

  specify "should require name" do
    lambda {
      t = create_project_status(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(ProjectStatus, :count)
 end
 
 specify "should require description" do
    lambda {
      t = create_project_status(:description => nil)
      t.errors.on(:description).should.not.be.nil
    }.should.not.change(ProjectStatus, :count)
  end
 
  specify "name should be unique" do
    @project = create_project_status()
    @project.save
    @project = create_project_status()
    @project.should.not.validate
  end   

 def create_project_status(options = {})
    ProjectStatus.create({ :name => 'TestProjectStatus', :description => 'My Description' }.merge(options))  
  end 
end
