require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectStatus do
  before do
    @project_status = Factory(:project_status)
  end
  
  it "should validate the presence of name" do
    @project_status.should validate_presence_of(:name)
  end
  it "should validate the uniqueness of name" do
    @project_status.should validate_uniqueness_of(:name)
  end
  it "should validate the presence of description" do
    @project_status.should validate_presence_of(:description)
  end
  
  describe "class methods" do
    before do
      @project_status_active = ProjectStatus.active || Factory(:project_status, { :name => "Active" })
      @project_status_completed = ProjectStatus.completed || Factory(:project_status, { :name => "Completed" })
    end
    describe "started method" do
      it "should return the first Active ProjectStatus record" do
        ProjectStatus.started.should == @project_status_active
      end
    end
    describe "completed method" do
      it "should return the first Completed ProjectStatus record" do
        ProjectStatus.completed.should == @project_status_completed
      end
    end
    describe "public method" do
      it "should return the Active & Completed ProjectStatus records" do
        ProjectStatus.public_statuses.should == [@project_status_active, @project_status_completed]
      end
    end
    describe "public_ids method" do
      it "should return the Active & Completed ProjectStatus ids" do
        ProjectStatus.public_ids.should == [@project_status_active.id, @project_status_completed.id]
      end
    end
  end
end