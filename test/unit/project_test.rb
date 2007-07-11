require File.dirname(__FILE__) + '/../test_helper'

#class BusAdmin::ProjectTest < Test::Unit::TestCase
context "Projects" do
  
  fixtures :projects, :milestones

  NUMBER_OF_DAYS_UNTIL_END = 30
    
  def setup
    @project = Project.new
    @fixture_project = Project.find(:first)
  end
  
  specify "The project should have a name & description" do
    @fixture_project.name.should.not.be.nil
    @fixture_project.description.should.not.be.nil
  end
  
  specify "nil program id should not validate" do
    @fixture_project.program_id = nil
    @fixture_project.should.not.validate
  end
  
  def test_percent_raised
    @project.total_cost = 100
    @project.dollars_raised = 45
    expected = 45
    assert_equal expected, @project.get_percent_raised
  end
  
  specify "total cost of zero should produce nil percent raised" do
    @project.total_cost = 0
    @project.dollars_raised = 45
    @project.get_percent_raised.should.equal nil
  end
  
  def test_days_remaining #need to mock out time.now
    project = Project.find(:first)
    project.end_date = '2007-08-08'
    #Time.now = '2007-08-02'
    #assert_equal @project.days_remaining, 6
  end
  
  specify "should find projects with a status of started" do # test_started_projects
    started_projects = Project.find(:all, :conditions => "project_status_id = 2").size
    total_projects = Project.find(:all).size
    total_projects.should.equal 3
    started_projects.should.equal 2
  end
  
  specify "should return total number of milestones for a project" do
    Project.find(1).milestones.find(:all).size.should.equal 2
  end
    
  specify "should return number of milestones with requested status" do
    project = Project.find(1)
    project.get_number_of_milestones_by_status(1).should.equal 2
    #assert_equal 2, milestones
  end
  
  specify "should return number or projects ending within specified number of days" do    
    @projects = Project.find(:all)
    @projects.each do |p|
      p.end_date = Time.now + 86400 #set end date to one day from now
      p.update
    end    
    Project.projects_nearing_end(NUMBER_OF_DAYS_UNTIL_END).size.should.equal Project.find(:all).size
    project_one = Project.find(:first)
    project_one.end_date = Date.today  + NUMBER_OF_DAYS_UNTIL_END + 2 #increase end date beyond limit
    project_one.update
    expected = Project.find(:all).size - 1
    Project.projects_nearing_end(NUMBER_OF_DAYS_UNTIL_END).size.should.equal expected    
  end  
  
  specify "should return zero days remaining if no end date set" do
      project = Project.new
      project.name = "bob"
      project.start_date = "2007-06-06"
      project.end_date = nil
      project.days_remaining.should.be.nil   
 end
 
  def test_total_costs
    assert_equal 2100, Project.total_costs
  end
  
  def test_total_money_raised
    assert_equal 150, Project.total_money_raised
  end
  
  def test_total_percent_raised
    assert_equal 7, Project.total_percent_raised.floor
  end
  
  specify "percent raised should be 100 if total cost is 0 or nil" do       
    projects = Project.find(:all)
    projects.each do |p|
      p.total_cost = nil
      p.update
    end
    Project.total_costs.should.be.nil
    Project.total_percent_raised.to_i.should.equal 100
    projects.each do |p|
      p.total_cost = 0
      p.update
    end    
    puts Project.total_percent_raised.to_i.should.equal 100    
  end
  
  specify "percent raised should be 0 if total raised is 0" do       
    projects = Project.find(:all)
    projects.each do |p|
      p.dollars_raised = 0
      p.update
    end
    Project.total_percent_raised.to_i.should.equal 0
  end
end
