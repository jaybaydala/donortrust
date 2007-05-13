require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < Test::Unit::TestCase
  fixtures :contacts

  def test_invalid_with_empty_names
    contact = Contact.new
    
    assert !contact.valid?
    assert contact.errors.invalid?(:first_name)
    assert contact.errors.invalid?(:last_name)
  end

  def test_save_without_first_and_last_name
    contact = Contact.new
    assert !contact.save
  end
  
  def test_partner_relationship
    contact = Contact.new
    contact.id = 1
    
    partner1 = Partner.new(:name => "p1")
    partner2 = Partner.new(:name => "p2")
    
    assert contact.partners.empty?
    
    contact.partners << partner1
    contact.partners << partner2
    
    assert !contact.partners.empty?
  end
end
