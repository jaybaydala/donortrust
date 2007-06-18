module BusAdmin::ProgramsHelper

  def number_of_programs
    @total = Program.total_programs
  end
  
  def get_programs
    @all_programs = Program.get_programs
  end
end
