class BusAdmin::HomeController < ApplicationController
  before_filter :login_required

  include BusAdmin::ProjectsHelper
  include BusAdmin::ProgramsHelper
  
  def index
    @total_partners = Partner.find(:all).size #get_projects 
    @all_projects = Project.find(:all)#get_projects 
    @total_projects = @all_projects.size
    @total_programs = Program.find(:all).size 
    @all_programs = Program.find(:all)#get_programs
    @total_money_raised = Project.total_money_raised #total_money_raised
    @total_project_costs = Project.total_costs
    @total_money_spent = Project.total_money_spent #total_money_spent
    @total_percent_raised = Project.total_percent_raised
  end
  
end
