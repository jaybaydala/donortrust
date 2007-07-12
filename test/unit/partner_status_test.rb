#class BusAdmin::PartnerStatusTest < Test::Unit::TestCase
#  fixtures :partner_statuses
#end
require File.dirname(__FILE__) + '/../test_helper'

context "PartnerStatuses" do
  fixtures :partner_statuses, :partners

  def clean_new_instance( overrides = {})
    # Build (and return) an instance starting from known (expected) valid attribute
    # values, processing overides for any/all specified attributes
    opts = {
      :name => "xyzstatusxyz",
      :description => "Valid description for status"
    }.merge( overrides )
    PartnerStatus.new( opts )
  end

  setup do
#    @status = PartnerStatus.find(1)
#    @status = partner_statuses( :one )
  end

  specify "new clean instance should validate" do
    clean_new_instance( ).should.validate
  end

  specify "nil name should not validate" do
    clean_new_instance( :name => nil ).should.not.validate
  end

  specify "empty name should not validate" do
    clean_new_instance( :name => "" ).should.not.validate
  end

  specify "blank name should not validate" do
    clean_new_instance( :name => " " ).should.not.validate
  end

  specify "nil description should not validate" do
    PartnerStatus.new( :description => nil ).should.not.validate
  end

  specify "empty description should not validate" do
    PartnerStatus.new( :description => "" ).should.not.validate
  end

  specify "blank description should not validate" do
    PartnerStatus.new( :description => " " ).should.not.validate
  end

  specify "new duplicate name should not validate" do
    clean_new_instance( :name => partner_statuses( :one ).name ).should.not.validate
  end

  specify "new original name should validate" do
    clean_new_instance( :name => "new name" ).should.validate
  end

  specify "modify existing record to nil name should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.name = nil
    @sts.should.not.validate
  end

  specify "modify existing record to empty name should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.name = ""
    @sts.should.not.validate
  end

  specify "modify existing record to blank name should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.name = " "
    @sts.should.not.validate
  end

  specify "modify existing record to nil description should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.description = nil
    @sts.should.not.validate
  end

  specify "modify existing record to empty description should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.description = ""
    @sts.should.not.validate
  end

  specify "modify existing record to blank description should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.description = " "
    @sts.should.not.validate
  end

  specify "modify existing record to (other) existing name should not validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.name = partner_statuses( :two ).name
    @sts.should.not.validate
  end

  specify "modify existing record to new unigue name should validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.name = "new one"
    @sts.should.validate
  end

  specify "modify description of existing record should validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.description = "some new description"
    @sts.should.validate
  end

  specify "modify description of existing record to duplicate of other should validate" do
    @sts = PartnerStatus.find( partner_statuses( :one ).id )
    @sts.description = partner_statuses( :two ).description
    @sts.should.validate
  end

  specify "destroy existing (unused) record should validate" do
    @sts = PartnerStatus.find( partner_statuses( :three ).id )
    @sts.destroy.should.validate
  end

## hpd how to verify that destroy fails.  As is this gets an exception instead of catching
#  specify "destroy record used by Partner should not validate" do
#    @sts = PartnerStatus.find( partner_statuses( :one ).id )
#    @sts.destroy.should.raise "Can not destroy a PartnerStatus that has Partners"
#  end

end
