require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::ProjectsController do
  
  before(:each) do
    @project = Factory(:project)
    Project.stub(:find).and_return(@project)
    @project.stub(:likes_count).and_return(3)
  end
  
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end

  it "should respond_to the like method" do
    controller.should respond_to('like')
  end

  it "should call like method with network and user when a project is liked" do
    @project.should_receive("like").with("facebook", nil)
    post 'like', :id => @project.id, :network => "facebook", :like => "true"
  end

  it "should call unlike method with network and user when a project is unliked" do
    @project.should_receive("unlike").with("facebook", nil)
    post 'like', :id => @project.id, :network => "facebook", :like => "false"
  end

  it "should return project likes" do
    post 'like', :id => @project.id, :network => "facebook", :like => "true"
    response.body.should == {:likes_count => 3}.to_json
  end

end
