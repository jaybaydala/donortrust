require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::GiftsController do
  before do
    @user = mock_model(User)

    @project = mock_model(Project)
    @project.stub!(:name).and_return("Spec Project")
    @project.stub!(:fundable?).and_return(true)
    
    @gift = mock_model(Gift)
    Gift.stub!(:new).and_return(@gift)
    @gift.stub!(:project).and_return(@project)
  end

  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  %w( edit update destroy ).each do |m|
    it "should not respond_to the #{m} method" do
      controller.should_not respond_to(m)
    end
  end

  %w(index new create show open unwrap preview).each do |m|
    it "should respond_to the #{m} method" do
      controller.should respond_to(m)
    end
  end
  
  it "should redirect to new on index" do
    get 'index'
    response.should redirect_to(new_dt_gift_path)
  end
  
  
end