require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectStatus do
  before do
    @project_status = ProjectStatus.generate!
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
      @project_status_started = ProjectStatus.generate!(:name => "Started")
      @project_status_completed = ProjectStatus.generate!(:name => "Completed")
    end
    describe "started method" do
      it "should return the first Started ProjectStatus record" do
        ProjectStatus.started.should == @project_status_started
      end
    end
    describe "completed method" do
      it "should return the first Completed ProjectStatus record" do
        ProjectStatus.completed.should == @project_status_completed
      end
    end
    describe "public method" do
      it "should return the Started & Completed ProjectStatus records" do
        ProjectStatus.public.should == [@project_status_started, @project_status_completed]
      end
    end
    describe "public_ids method" do
      it "should return the Started & Completed ProjectStatus ids" do
        ProjectStatus.public_ids.should == [@project_status_started.id, @project_status_completed.id]
      end
    end
  end
end