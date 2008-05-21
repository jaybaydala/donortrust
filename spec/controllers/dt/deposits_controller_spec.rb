require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::DepositsController do
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  
end
