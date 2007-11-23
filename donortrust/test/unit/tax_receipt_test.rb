require File.dirname(__FILE__) + '/../test_helper'

context "Tax Receipt" do
  specify "should create a TaxReceipt" do
    lambda {
      t = create_tax_receipt()
    }.should.change(TaxReceipt, :count)
  end
  
  specify "should require a first_name, last_name, email, address, city, province, postal_code and country" do
    %w(first_name last_name email address city province postal_code country).each do |field|
      lambda {
        t = create_tax_receipt(field.to_sym => nil)
        t.errors.on(field.to_sym).should.not.be.nil
      }.should.not.change(TaxReceipt, :count)
    end
  end
  
  specify "should not require a user" do
    lambda {
      t = create_tax_receipt(:user_id => nil)
      t.errors.on(:user_id).should.be.nil
    }.should.change(TaxReceipt, :count)
  end

  specify "country must be Canada at this time" do
    lambda {
      t = create_tax_receipt(:country => "USA")
      t.errors.on(:country).should.not.be.nil
    }.should.not.change(TaxReceipt, :count)
  end

  private
  def create_tax_receipt(options = {})
    TaxReceipt.create({ :first_name => 'Tim', :last_name => 'Example', :email => 'tim@example.com', :address => '123 Foo Street North', :city => 'Here', :province => 'There', :postal_code => 'H0H 0H0', :country => 'Canada', :user_id => 1 }.merge(options))
  end
end
