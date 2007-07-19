require File.dirname(__FILE__) + '/../test_helper'

#class BusAdmin::PartnersTest < Test::Unit::TestCase

context "Partners" do
  fixtures :partners, :projects#, :programs
  
  def setup    
    @fixture_partner = Partner.find(:first)
  end
  
    
#  def create_instance(overrides = {})
#    opts = {
#      :id => 1,
#      :name => "name",
#      :description => "description",
#      :partner_status_id => 1,
#      :partner_type_id => 1
#    }.merge(overrides)
#    
#    Partner.new(opts)
#  end
  
#  def test_create_new
#    assert_valid create_instance
#  end
  
#  def test_create_blank_name
#    assert_invalid(create_instance, :name, '')
#  end
#  
#  def test_long_name
#    assert_invalid(create_instance, :name, '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890')
#  end
#  
#  def test_long_description
#    assert_invalid(create_instance, :description, '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890')
#  end

  def test_total_projects
    assert_equal 3, Partner.find(:first).total_projects
  end
  
  def test_get_number_of_projects_by_status    
    assert_equal 1, Partner.find(:first).get_number_of_projects_by_status(1)
  end
  
#  def test_get_number_of_projects
#    partner = Partner.find(:first)
#    number = Projects.find(:all, :conditions => "partner_id = " + partner.id).size
#    puts number
#  end

#  specify "The partner should have a name partner_status_id & partner_type id" do
#    @fixture_partner.name.should.not.be.nil
#    @fixture_partner.partner_status_id.should.not.be.nil
#    @fixture_partner.partner_type_id.should.not.be.nil
#  end

  specify "The total cost for a partner should not be nil and should be greater than 0" do
    projects = Project.find(:all, :conditions => "partner_id = " + @fixture_partner.id.to_s)    
    projects.size.should.be > 
    total_cost = 0
    projects.each do |project|
      total_cost += project.total_cost
    end
    total_cost.should.not.be.nil
    total_cost.should.be > 0
    total_cost.should.be == @fixture_partner.get_total_costs
#    programs = []
#    projects.each do |project|
#      programs << project.program_id
#    end
#    programs.should.not.be.nil
#    programs.size.should.be > 0    
  end
  
  specify "The total cost for a partner should not be nil and should be greater than 0" do
    projects = Project.find(:all, :conditions => "partner_id = " + @fixture_partner.id.to_s)    
    projects.size.should.be > 0
    total_raised = 0
    projects.each do |project|
      total_raised += project.dollars_raised
    end
    total_raised.should.not.be.nil
    total_raised.should.be > 0
    total_raised.should.be == @fixture_partner.get_total_raised
  end
  
  specify "Total percent raised should accept zero" do
    projects = Project.find(:all, :conditions => "partner_id = " + @fixture_partner.id.to_s)
    @fixture_partner.get_total_percent_raised.should.not.be.nil
    projects.each do |project|
      project.total_cost = 0
      project.update
    end    
    @fixture_partner.get_total_percent_raised.should.not.be.nil
    @fixture_partner.get_total_percent_raised.to_i.should.be == 0
  end
end
  
