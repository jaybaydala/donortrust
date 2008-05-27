require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CheckoutsHelper do
  it "should have titles" do
    helper.titles.should == %w(Mr. Mrs. Ms. Miss Dr. Rev.)
  end
  
  #it "should render checkout_nav" do
  #  helper.checkout_nav.should render_template("dt/checkouts/checkout_nav")
  #end
  
  it "should return the expiry_months" do
    helper.expiry_months.should == [["01", 1], ["02", 2], ["03", 3], ["04", 4], ["05", 5], ["06", 6], ["07", 7], ["08", 8], ["09", 9], ["10", 10], ["11", 11], ["12", 12]]
  end
  
  it "should return the expiry_years" do
    helper.expiry_years.should == (Time.now.year..(Time.now.year+7)).collect{|y| [y, y]}
  end
end
