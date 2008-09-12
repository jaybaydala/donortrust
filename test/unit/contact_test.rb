require File.dirname(__FILE__) + '/../test_helper'

context "Contact Tests " do
  fixtures :contacts
  setup do
    @contact = Contact.find(1)
  end
   
  specify "should create contact" do
      Contact.should.differ(:count).by(1) {create_contact} 
  end
     
  specify "should require first name" do
    lambda {
       t = create_contact(:first_name => nil)
       t.errors.on(:first_name).should.not.be.nil
    }.should.not.change(Contact, :count)
  end
   
  specify "should require last name" do
    lambda {
        t = create_contact(:last_name => nil)
        t.errors.on(:last_name).should.not.be.nil
    }.should.not.change(Contact, :count)
   end
    
  specify "fullname should concat 'first_name last_name'" do
    contact = Contact.new( :first_name => 'testy', :last_name => 'testerson')
    contact.fullname.should == "testy testerson"
  end
    
#  specify "duplicat first and last name should not validate" do
#    @contact1 = Contact.new( :first_name => @contact.first_name, :last_name => @contact.last_name )
#    @contact1.should.not.validate
#  end
    
  def create_contact(options = {})
      Contact.create({ :first_name => 'FirstName', :last_name => 'LastName', :phone_number => '403-978-3245', :fax_number => '403-978-3246', :email_address => 'test@test.ca', :web_address => 'www.google.ca', :department => 'department', :place_id => '1', :address_line_1 => '2127 50th Ave SW', :address_line_2 => 'address line 2', :postal_code => 'T2T4B2' }.merge(options))  
  end                                                          
end
