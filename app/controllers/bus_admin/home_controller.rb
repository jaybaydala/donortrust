class BusAdmin::HomeController < ApplicationController

  include BusAdmin::ProjectsHelper
  include BusAdmin::ProgramsHelper
  
  def index
    @total_projects = number_of_projects
    @all_projects = get_projects 
    @total_programs = number_of_programs 
    @all_programs = get_programs
  end
  
end
