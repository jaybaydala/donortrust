require File.dirname(__FILE__) + '/../test_helper'

context "PartnerStatuses" do
  fixtures :partner_statuses

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :name => "xyzstatusxyz",
      :description => "Valid description for status"
    }.merge( overrides )
    PartnerStatus.new( opts )
  end

  specify "modify existing record to nil name should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.name = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to empty name should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.name = ""
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to blank name should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.name = " "
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to nil description should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.description = nil
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to empty description should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.description = ""
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to blank description should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.description = " "
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to (other) existing name should not validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.name = partner_statuses( :two ).name
    instance.should.not.validate
    instance.save.should.equal( false )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify existing record to new unigue name should validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.name = "new one"
    instance.should.validate
    instance.save.should.equal( true )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify description of existing record should validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.description = "some new description"
    instance.should.validate
    instance.save.should.equal( true )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "modify description of existing record to duplicate of other should validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :one ).id )
    instance.description = partner_statuses( :two ).description
    instance.should.validate
    instance.save.should.equal( true )
    PartnerStatus.count.should.equal( old_instance_count )
  end

  specify "destroy existing (unused) record should validate" do
    old_instance_count = PartnerStatus.count
    instance = PartnerStatus.find( partner_statuses( :three ).id )
    instance.destroy
    PartnerStatus.count.should.equal( old_instance_count - 1 )
  end
  
  specify "should create a partner status" do
      PartnerStatus.should.differ(:count).by(1) { create_partner } 
  end
  
  specify "name should be less then 25 Characters" do
      lambda {
        t = create_partner(:name=> 'This will enter more then 25 characters.')
        t.errors.on(:name).should.not.be.nil
      }.should.not.change(PartnerStatus, :count)
    end
    
  specify "description should be less then 250 Characters" do
    lambda {
      t = create_partner(:description=> 'This will enter more then Two hundred and 
      fifty characters into the column. This will enter more then Two hundred and 
      fifty characters into the column. This will enter more then Two hundred and 
      fifty characters into the column. This will enter more then Two hundred and 
      fifty characters into the column.')
      t.errors.on(:description).should.not.be.nil
    }.should.not.change(PartnerStatus, :count)
  end
    
  def create_partner(options = {})  
    PartnerStatus.create({ :name => 'Test', :description => 'description' }.merge(options))                          
  end 

## hpd how to verify that destroy fails.  As is this gets an exception instead of catching
## and displaying the failure.
#  specify "destroy record used by Milestone should not validate" do
#    old_instance_count = PartnerStatus.count
#    instance = PartnerStatus.find( partner_statuses( :one ).id )
#    instance.destroy.should.raise "Can not destroy a PartnerStatus that has Milestones"
#  end
end
