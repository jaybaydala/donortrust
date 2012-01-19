require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  before(:each) do
    @project = Factory(:project)
    @current_user = Factory(:user, :id => 111)
  end

  it "should include Likeable module" do
    Project.should include Likeable
  end

  context "likes_count method" do
    it "should have zero likes when fresh" do
      @project.likes_count.should == 0
    end
  end

  context "like method" do
    it "should increment likes_count by one when liked" do
      @project.like("local", @current_user)
      @project.likes_count.should == 1
    end

    # facebook and google will verify the user at their own end; we need
    # to check logged_in users for local likes
    it "should not allow a non-logged in user to like" do
      @project.like("local", nil)
      @project.likes_count.should == 0
    end
  end

  context "unlike method" do
    it "should decrement likes count by one when unliked" do
      @project.like("facebook", @current_user)
      @project.unlike("facebook", @current_user)
      @project.likes_count.should == 0
    end
  end

  context "liked_by? method" do

    it "should return true when a user has liked a project" do
      @project.like("local", @current_user)
      @project.liked_by?("local", @current_user)
    end
  end
end

