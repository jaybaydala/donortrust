require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectStatus do
  
  it "should validate the presence of name" do
    project_status = create_project_status
    project_status.should validate_presence_of(:name)
  end
  it "should validate the uniqueness of name" do
    project_status = create_project_status
    project_status.should validate_uniqueness_of(:name)
  end
  it "should validate the presence of description" do
    project_status = create_project_status
    project_status.should validate_presence_of(:description)
  end
  
  describe "started method" do
    it "should return the first Started ProjectStatus record" do
      project_status = create_started_project_status
      ProjectStatus.started.should == project_status
    end
  end
end