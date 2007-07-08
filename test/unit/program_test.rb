require File.dirname(__FILE__) + '/../test_helper'

class ProgramTest < Test::Unit::TestCase
  fixtures :programs, :contacts

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
end
