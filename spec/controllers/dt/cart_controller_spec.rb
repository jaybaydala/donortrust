require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CartController do
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  it "should implement the show method" do
    controller.should respond_to(:show)
  end
end
