require File.dirname(__FILE__) + '/../spec_helper'

describe TaxReceipt do

  context "for an individual" do
    it "is valid with a last name" do
      individual = Factory(:user, :group => false, :first_name => "John", :last_name => "Doe")
      rec = Factory(:tax_receipt, :user => individual)
      rec.should be_valid
    end
    it "is not valid without a last name" do
      individual = Factory(:user, :group => false, :first_name => "John", :last_name => "Doe")
      rec = Factory.build(:tax_receipt, :user => individual, :last_name => nil)
      rec.should_not be_valid
    end
  end

  context "for a group" do
    it "is valid without a last name" do
      group = Factory(:user, :group => true, :first_name => "John", :last_name => nil)
      rec = Factory(:tax_receipt, :user => group)
      rec.should be_valid     
    end    
  end

end
