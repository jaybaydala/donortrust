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
  
  specify "get_percent_raised should return 6 for project 1" do
    @project = Project.find(1)
    expected = 6
    expected.should.equal @project.get_percent_raised
  end
  
  specify "total cost of zero should produce 0 percent raised" do
    @project.total_cost = 0
    @project.get_percent_raised.should.equal 0
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
  
  specify "should return nil days remaining if no end date set" do
    project = Project.new
    project.name = "bob"
    project.start_date = "2007-06-06"
    project.end_date = nil
    project.days_remaining.should.be.nil   
  end
 
  specify "total_cost should equal 12000" do
    Project.total_costs.should.equal 12000
  end
  
  specify "total_money_raised should equal 150" do
    Project.total_money_raised.should.equal 600
  end
  
  specify "total_percent_raised.floor should equal 5" do
    Project.total_percent_raised.floor.should.equal 5
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
    #puts Project.total_percent_raised.to_i.should.equal 100    
  end
  
  specify "percent raised should be 0 if total raised is 0" do       
    projects = Project.find(:all)
    projects.each do |p|
      Investment.destroy_all(:project_id => p.id)
    end
    Project.total_percent_raised.to_i.should.equal 0
  end

  specify "dollars_raised should equal the Investments in the project" do
    @project = Project.find(1)
    total = 0
    Investment.find(:all, :conditions => {:project_id => @project.id}).each do |investment|
      total = total + investment.amount
    end
    @project.dollars_raised.should.equal total
  end

end
