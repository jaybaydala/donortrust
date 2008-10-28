require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::BulkGiftsController do
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  %w( destroy ).each do |m|
    it "should not respond the #{m} method" do
      controller.should_not respond_to(m)
    end
  end
  
  %w(index new create).each do |m|
    it "shoud respond to the #{m} method" do
      controller.should respond_to(m)
    end
  end
  
  it "should redirect to new on index" do
    get 'index'
    response.should redirect_to(new_dt_bulk_gift_path)
  end
  
  describe "new action" do
  end
  
  describe "create action" do
  end
  
  
end