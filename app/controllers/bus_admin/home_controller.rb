class BusAdmin::HomeController < ApplicationController
  before_filter :login_required

  include BusAdmin::ProjectsHelper
  include BusAdmin::ProgramsHelper
  
  def index
    @total_projects = number_of_projects
    @all_projects = get_projects 
    @total_programs = number_of_programs 
    @all_programs = get_programs
    @total_money_raised = total_money_raised
    @total_project_costs = total_project_costs
    @total_money_spent = total_money_spent
    @total_percent_raised = Project.total_percent_raised
  end
  
end
