require File.dirname(__FILE__) + '/../test_helper'

#class ProgramTest  Test::Unit::TestCase
context "Programs" do
  fixtures :programs, :contacts, :projects

  def setup    
    @fixture_program = Program.find(:first)
  end
  
  def test_invalid_with_empty_name
    program = Program.new
    program.contact_id = 1
    
    assert !program.valid?
    assert program.errors.invalid?(:name)
  end

  def test_invalid_with_empty_contact_id
    program = Program.new
    program.name = "bob's program"
    
    assert !program.valid?
    assert program.errors.invalid?(:contact_id)
  end
    
  def test_save_without_name
    program = Program.new
    program.contact_id = 1
    
    assert !program.save
  end
  
  def test_save_without_contact_id
    program = Program.new
    program.name = "bob's program"
    
    assert !program.save
  end
  
  def test_unique_name
    program = Program.new(:name => programs(:one).name)
    assert !program.valid?
  end
  
  
  specify "The total raised for a program should not be nil and should be greater than 0" do
    projects = Project.find(:all, :conditions => "program_id = " + @fixture_program.id.to_s)
    projects.size.should.be > 0
    total_raised = 0
    projects.each do |project|
      total_raised += project.dollars_raised
    end
    total_raised.should.not.be.nil
    total_raised.should.be > 0
    total_raised.should.be == @fixture_program.get_total_raised
  end
  
  specify "The total cost for a program should not be nil and should be greater than 0" do
    projects = Project.find(:all, :conditions => "program_id = " + @fixture_program.id.to_s)
    projects.size.should.be > 0
    total_cost = 0
    projects.each do |project|
      total_cost += project.total_cost
    end
    total_cost.should.not.be.nil
    total_cost.should.be > 0
    total_cost.should.be == @fixture_program.get_total_costs
  end
end
