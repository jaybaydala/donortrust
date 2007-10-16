require File.dirname(__FILE__) + '/../test_helper'

#class BusAdmin::PartnersTest < Test::Unit::TestCase

context "Partners" do
  fixtures :partners, :projects#, :programs
  
  def setup    
    @fixture_partner = Partner.find(:first)
  end
  
  specify "should create a partner" do
      Partner.should.differ(:count).by(1) { create_partner } 
  end
  
  def test_total_projects
    assert_equal 3, Partner.find(:first).total_projects
  end
  
  def test_get_number_of_projects_by_status    
    assert_equal 1, Partner.find(:first).get_number_of_projects_by_status(1)
  end
  
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
  
#  specify "The total cost for a partner should not be nil and should be greater than 0" do
#    projects = Project.find(:all, :conditions => "partner_id = " + @fixture_partner.id.to_s)    
#    projects.size.should.be > 0
#    total_raised = 0
#    projects.each do |project|
#      total_raised += project.dollars_raised
#    end
#    total_raised.should.not.be.nil
#    total_raised.should.be > 0
#    total_raised.should.be == @fixture_partner.get_total_raised
#  end
  
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
  
  specify "should require name" do
    lambda {
      t = create_partner(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(Partner, :count)
  end
   
  specify "should require description" do
    lambda {
      t = create_partner(:description => nil)
      t.errors.on(:description).should.not.be.nil
    }.should.not.change(Partner, :count)
  end
    
  specify "should require partner_type_id" do
    lambda {
      t = create_partner(:partner_type_id => nil)
      t.errors.on(:partner_type_id).should.not.be.nil
    }.should.not.change(Partner, :count)
  end
    
  specify "should require partner_status_id" do
    lambda {
      t = create_partner(:partner_status_id => nil)
      t.errors.on(:partner_status_id).should.not.be.nil
    }.should.not.change(Partner, :count)
  end
  
  specify "name should be less then 50 Characters" do
    lambda {
      t = create_partner(:name=> 'This will enter more then fifty characters into the column')
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(Partner, :count)
  end
    
  specify "description should be less then 1000 Characters" do
    lambda {
      t = create_partner(:description=> 'This will enter more then one thousand characters 
        into the column. This will enter more then one thousand characters into the 
        column. This will enter more then one thousand characters into the column. This 
        will enter more then one thousand characters into the column. This will enter 
        more then one thousand characters into the column. This will enter more then one 
        thousand characters into the column. This will enter more then one thousand 
        characters into the column. This will enter more then one thousand characters 
        into the column. This will enter more then one thousand characters into the 
        column. This will enter more then one thousand characters into the column. This 
        will enter more then one thousand characters into the column. This will enter 
        more then one thousand characters into the column. This will enter more then 
        one thousand characters into the column. This will enter more then one thousand 
        characters into the column. This will enter more then one thousand characters 
        into the column.')
      t.errors.on(:description).should.not.be.nil
    }.should.not.change(Partner, :count)
  end
  
  def create_partner(options = {})
    Partner.create({ :name => 'Test Name', :description => 'My Description', :website => 'www.google.ca', :partner_type_id => 1, :partner_status_id => 1, :business_model => 'Test model', :funding_sources => 'Test Fund', :mission_statement => 'Test Mission Statement', :philosophy_dev => 'Test Philosophy', :note => 'Test Note' }.merge(options))  
  end                                                          
     
end
  
