require File.dirname(__FILE__) + '/../test_helper'

context "Contaccts" do
  fixtures :contacts

  setup do
    @contact = Contact.find(1)
  end
  
  specify "The contact should have a first and last name" do
    @contact.first_name.should.not.be.nil
    @contact.last_name.should.not.be.nil
  end
  
  specify "duplicat first and last name should not validate" do
    @contact1 = Contact.new( :first_name => @contact.first_name, :last_name => @contact.last_name )
    @contact1.should.not.validate
  end

  specify "nil first_name should not validate" do
    @contact.first_name = nil
    @contact.should.not.validate
  end
  
  specify "nil last_name should not validate" do
    @contact.last_name = nil
    @contact.should.not.validate
  end

end